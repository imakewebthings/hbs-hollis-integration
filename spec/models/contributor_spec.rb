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

require 'spec_helper'

describe Contributor do
  it { should respond_to :surname }
  it { should respond_to :given_name }
  it { should respond_to :title }
  it { should respond_to :primary_unit }
  it { should respond_to :name_slug }
  it { should respond_to :primary_unit_slug }
  it { should respond_to :role }
  it { should respond_to :person_id }
end
