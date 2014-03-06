require 'csv' 

namespace :csv do
  options = {
    col_sep: "\t",
    headers: true,
    header_converters: :symbol,
    converters: :integer
  }

  desc 'Create database records from contributor CSV file'
  task :contributors => :environment do
    Rails.logger.level = Logger::ERROR
    file = 'lib/tasks/csv/contributors.csv'
    puts 'Destroying existing contributor records'
    Contributor.destroy_all
    puts 'Generating new records from CSV'
    contibutors_csv = CSV.read(file, options)
    contributors = contributors_csv.collect do |row|
      is_hbs = row.fields[row.headers.index(:contributor_type)] == 'HBS'
      is_editor = row.fields[row.headers.index(:contributor_role)] == 'editor'
      putc '.'
      if !is_hbs || is_editor
        next
      end
      valid_publication_types = ['Book', 'Book Component']
      publication_type = row.fields[row.headers.index(:publication_type)]
      unless valid_publication_types.include? publication_type
        next
      end
      name_parts = row.fields[row.headers.index(:title_title)].split
      name_slug = name_parts.join(' ').parameterize
      surname = name_parts.pop
      given_name = name_parts.join ' '
      primary_unit = row.fields[row.headers.index(:primary_unit)]
      if primary_unit == 'NULL'
        primary_unit = nil
      end
      title = row.fields[row.headers.index(:title)]
      title = nil if title == 'NULL'
      primary_unit_slug = primary_unit ? primary_unit.parameterize : nil
      {
        surname: surname,
        given_name: given_name,
        role: row.fields[row.headers.index(:person_role)],
        primary_unit: primary_unit,
        person_id: row.fields[row.headers.index(:person_id)],
        title: title,
        name_slug: name_slug,
        primary_unit_slug: primary_unit_slug
      }
    end.compact.uniq do |contributor|
      contributor[:person_id]
    end
    puts "\nInserting generated records"
    ActiveRecord::Base.transaction do
      contributors.each {|c| Contributor.create c }
    end
    puts "#{contributors.length} records inserted"
  end

  desc 'Find coauthors for contributors'
  task :coauthors => :environment do
    Rails.logger.level = Logger::ERROR
    puts 'Destroying old coauthorship associations'
    Coauthorship.destroy_all
    contributors = Contributor.all.pluck(:person_id)
    file = 'lib/tasks/csv/contributors.csv'
    puts 'Reading contributor CSV...'
    contributor_csv = CSV.read(file, options)
    puts 'Grouping contributors by publication...'
    product_hash = Hash.new {|hash, key| hash[key] = [] }
    contributor_csv.each do |row|
      product_id = row.fields[row.headers.index(:product_id)]
      author_id = row.fields[row.headers.index(:person_id)]
      if contributors.include? author_id
        product_hash[product_id].push author_id
      end
    end
    coauthor_hash = Hash.new {|hash, key| hash[key] = [] }
    puts 'Determining coauthors'
    product_hash.each do |product, authors|
      authors.each do |author|
        coauthor_hash[author].push(authors)
      end
    end
    coauthor_hash.each do |author, coauthors|
      coauthors.flatten!
      coauthors.uniq!
      coauthors.delete author
      coauthors.each do |coauthor|
        putc '.'
        Coauthorship.create(author_id: author, coauthor_id: coauthor)
      end
    end
    puts "\n#{Coauthorship.count} associations created."
  end

  desc 'Create database records from topic CSV file'
  task :topics => :environment do
    Rails.logger.level = Logger::ERROR
    puts 'Destroying existing topic records'
    Topic.destroy_all
    puts 'Generating new records from CSV'
    file = 'lib/tasks/csv/topics.csv'
    topics = CSV.read(file, options).collect do |row|
      putc '.'
      name = row.fields[row.headers.index(:topic)]
      {
        record_count: row.fields[row.headers.index(:record_count)],
        name: name,
        slug: name.parameterize
      }
    end
    ActiveRecord::Base.transaction do
      topics.each {|t| Topic.create t }
      puts "\nInserting generated records"
    end
    puts "#{topics.length} records inserted"
  end
end
