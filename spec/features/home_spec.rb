require 'spec_helper'

describe '/' do
  before do
    visit root_path
  end

  specify { page.should have_selector 'header.fat p' }
  specify { page.should have_selector 'nav.search-by' }
end
