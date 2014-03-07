# == Schema Information
#
# Table name: topics
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  slug         :string(255)
#  record_count :integer
#  lcsh         :string(255)
#

class Topic < ActiveRecord::Base
end
