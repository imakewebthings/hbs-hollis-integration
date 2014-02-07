# == Schema Information
#
# Table name: contributors
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  role              :string(255)
#  primary_unit      :string(255)
#  person_id         :integer
#  title             :string(255)
#  name_slug         :string(255)
#  primary_unit_slug :string(255)
#

class Contributor < ActiveRecord::Base
  def self.authors
    Rails.cache.fetch(:authors) { self.authors! }
  end

  def self.authors!
    self.uniq.select(:name, :name_slug).order(:name_slug)
  end

  def self.author_by_slug(name_slug)
    puts name_slug
    puts self.authors.class
    puts self.authors.find_by_name_slug name_slug
    self.authors.find_by_name_slug name_slug
  end

  def self.units
    Rails.cache.fetch(:units) { self.units! }
  end

  def self.units!
    self.uniq
      .where("contributors.primary_unit_slug IS NOT NULL")
      .select(:primary_unit, :primary_unit_slug)
      .order(:primary_unit_slug)
  end
end
