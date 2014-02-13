require 'spec_helper'

describe Topic do
  it { should respond_to :name }
  it { should respond_to :slug }
  it { should respond_to :record_count }
end
