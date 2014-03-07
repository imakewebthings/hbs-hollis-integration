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

require 'spec_helper'

describe Topic do
  it { should respond_to :name }
  it { should respond_to :slug }
  it { should respond_to :record_count }
end
