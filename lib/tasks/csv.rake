require 'csv' 
require 'json'
require 'open-uri'

namespace :csv do
  options = {
    col_sep: "\t",
    headers: true,
    header_converters: :symbol,
    converters: :integer
  }
  LC_ENDPOINT = 'http://hlslwebtest.law.harvard.edu/v1/api/item/?filter=collection:hollis_catalog,hbs_edu&limit=250'

  desc 'Create database records from contributor CSV file'
  task :contributors => :environment do
    file = 'lib/tasks/csv/contributors.csv'
    puts 'Destroying existing contributor records'
    Contributor.destroy_all
    puts 'Generating new records from CSV'
    contributors = CSV.read(file, options).collect do |row|
      putc '.'
      if row.fields[row.headers.index(:contributor_type)] != 'HBS'
        next
      end
      valid_publication_types = ['Book', 'Book Component', 'Working Paper']
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
      primary_unit_slug = primary_unit ? primary_unit.parameterize : nil
      {
        surname: surname,
        given_name: given_name,
        role: row.fields[row.headers.index(:person_role)],
        primary_unit: primary_unit,
        person_id: row.fields[row.headers.index(:person_id)],
        title: row.fields[row.headers.index(:title)],
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

  desc 'Generate LCSH matches for Topics'
  task :lcsh => :environment do
    topics = Topic.where(lcsh: nil).pluck(:name, :slug)
    topics.each do |topic|
      query = CGI::escape topic.first
      slug = topic.last
      puts "STARTING TOPIC: #{query}"
      url = "#{LC_ENDPOINT}&filter=keyword:#{query}&filter=format:Book"
      docs = []
      2.times do |page|
        puts "...page #{page}"
        response = JSON.parse open("#{url}&start=#{page*250}").read
        docs.concat response['docs']
      end
      lcsh_freq = docs.reduce(Hash.new(0)) do |memo, item|
        if item['lcsh']
          item['lcsh'].each{|subject| memo[subject] += 1 } 
        end
        memo
      end.sort_by {|k, v| v }
      most_frequent = lcsh_freq.last ? lcsh_freq.last.first : nil;
      if most_frequent && most_frequent['HKS Faculty']
        most_frequent = lcsh_freq[-2] ? lcsh_freq[-2].first : nil;
      end
      puts "#{query} -> #{most_frequent}"
      Topic.find_by_slug(slug).update(lcsh: most_frequent)
    end
  end
end
