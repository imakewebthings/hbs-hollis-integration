require 'csv' 

namespace :csv do
  desc 'Create database records from contributor CSV file'
  task :contributors => :environment do
    file = 'lib/tasks/csv/contributors.csv'
    options = {
      col_sep: "\t",
      headers: true,
      header_converters: :symbol,
      converters: :integer
    }
    puts 'Destroying existing contributor records'
    Contributor.destroy_all
    puts 'Generating new records from CSV'
    contributors = CSV.read(file, options).collect do |row|
      putc '.'
      name = row.fields[row.headers.index(:title_title)].split.join(' ')
      primary_unit = row.fields[row.headers.index(:primary_unit)]
      if primary_unit == 'NULL'
        primary_unit = nil
      end
      primary_unit_slug = primary_unit ? primary_unit.parameterize : nil
      {
        name: name,
        role: row.fields[row.headers.index(:person_role)],
        primary_unit: primary_unit,
        person_id: row.fields[row.headers.index(:person_id)],
        title: row.fields[row.headers.index(:title)],
        name_slug: name.parameterize,
        primary_unit_slug: primary_unit_slug
      }
    end.select do |contributor|
      contributor[:role] == 'HBS Faculty'
    end.uniq do |contributor|
      contributor[:person_id]
    end
    puts "\nInserting generated records"
    ActiveRecord::Base.transaction do
      contributors.each {|c| Contributor.create c }
    end
    puts "#{contributors.length} records inserted"
  end
end
