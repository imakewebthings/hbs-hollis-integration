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
    contributors = CSV.read(file, options).collect do |row|
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
