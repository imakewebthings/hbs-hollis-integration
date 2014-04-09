require 'csv' 

namespace :csv do
  include ActiveSupport::Inflector

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
    contributors_csv = CSV.read(file, options)
    contributors = contributors_csv.collect do |row|
      is_hbs = row.fields[row.headers.index(:contributor_type)] == 'HBS'
      is_editor = row.fields[row.headers.index(:contributor_role)] == 'editor'
      putc '.'
      if !is_hbs || is_editor
        next
      end
      name_parts = row.fields[row.headers.index(:title_title)].split
      name_parts.reject! {|str| str == 'Jr.' }
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

  desc 'Fix contributor author names to match LC entries'
  task :fixnames => :environment do
    Rails.logger.level = Logger::ERROR
    puts 'Fixing contributor names'
    file = 'lib/tasks/csv/author_names.csv'
    names = CSV.read(file, options).collect do |row|
      name = row.fields[row.headers.index(:hbs_creator)]
      lc_names = row.fields[row.headers.index(:lc_names)] || ''
      {
        surname: name.split(', ')[0],
        given_name: name.split(', ')[1],
        lc_names: lc_names.split('%%')
      }
    end
    # Manual on-off cases
    Contributor.find_by_given_name('Dutch').update({
      given_name: 'Herman B.',
      name_slug: 'herman-b-leonard'
    })
    Contributor.find_by_surname('Linde').update({
      surname: 'van der Linde',
      given_name: 'Claas M.',
      name_slug: 'claas-m-van-der-linde'
    })
    Contributor.find_by_surname('Tella').update({
      surname: 'Di Tella',
      given_name: 'Rafael M.',
      name_slug: 'rafael-m-di-tella'
    })
    hit_count = 3
    names.each do |name|
      contributor = Contributor.where(surname: name[:surname])
      next if contributor.length == 0
      if contributor.length == 1
        c = contributor.first
        c.given_name = name[:given_name]
        c.name_slug = "#{name[:given_name]} #{c.surname}".parameterize
        c.lc_names = name[:lc_names].join(' OR ')
        hit_count += 1 
        c.save!
      else
        given_name_parts = name[:given_name].split(' ')
        initials = given_name_parts.map{|x| "#{x[0]}." }.join(' ')
        contributor.to_a.each do |c|
          # P. J. -> Paul J.
          initial_match = initials == c.given_name
          # J. -> John C.
          first_initial_match = initials.split(' ')[0] == c.given_name
          # L. Morgan -> Laura Morgan
          middle_match = false
          existing_name_parts = c.given_name.split(' ')
          if !initial_match && !first_initial_match && existing_name_parts.length == 2 && given_name_parts.length == 2
            middle_match = existing_name_parts[1] == given_name_parts[1] &&
                           existing_name_parts[0][0] == given_name_parts[0][0]
          end
          if initial_match || first_initial_match || middle_match 
            c.given_name = name[:given_name]
            c.name_slug = "#{name[:given_name]} #{c.surname}".parameterize
            c.lc_names = name[:lc_names].join(' OR ')
            hit_count += 1
            c.save!
          end
        end
      end
    end
    puts "#{hit_count} names adjusted"
  end

  desc 'Drop authors with no hits on their name in hbs_edu'
  task :compact => :environment do
    require 'open-uri'
    require 'json'
    puts 'Removing authors without hbs_edu records'
    Rails.logger.level = Logger::ERROR
    LC_ENDPOINT = 'http://hlslwebtest.law.harvard.edu/v1/api/item/?filter=collection:hbs_edu&filter=language:English&filter=creator_keyword:'
    hitcount = 0
    authors = Contributor.select(:id, :surname, :given_name).to_a
    authors.each do |author|
      name = "#{transliterate(author.surname)}, #{transliterate(author.given_name)}"
      response = JSON.parse open(LC_ENDPOINT + CGI::escape(name)).read
      if response['num_found'] == 0
        author.destroy!
        hitcount += 1
      end
    end
    puts "#{hitcount} authors removed"
  end

  desc 'Add biography data to contributors'
  task :biographies => :environment do
    Rails.logger.level = Logger::ERROR
    puts 'Reading biography CSV'
    file = 'lib/tasks/csv/hbs_edu_biographies.csv'
    hit_count = 0
    CSV.read(file, options).collect do |row|
      person_id = row.fields[row.headers.index(:person_id)]
      c = Contributor.find_by_person_id person_id
      next unless c
      c.brief_biography = row.fields[row.headers.index(:brief_biography)]
      c.full_biography = row.fields[row.headers.index(:full_biography)]
      c.save
      putc '.'
      hit_count += 1
    end
    puts "\n#{hit_count} biographies added"
  end
end
