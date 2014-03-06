class Coauthorship < ActiveRecord::Base
  belongs_to :author, class_name: 'Contributor', primary_key: 'person_id'
  belongs_to :coauthor, class_name: 'Contributor', primary_key: 'person_id'
end
