# == Schema Information
#
# Table name: coauthorships
#
#  id          :integer          not null, primary key
#  author_id   :integer          not null
#  coauthor_id :integer          not null
#

class Coauthorship < ActiveRecord::Base
  belongs_to :author, class_name: "Contributor", primary_key: "person_id"
  belongs_to :coauthor, class_name: "Contributor", primary_key: "person_id"
end
