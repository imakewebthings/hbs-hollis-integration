require 'spec_helper'

describe '/authors' do
  before do
    visit authors_path
  end

  specify { page.should have_selector 'header.fat' }
  specify { page.should have_selector '.search-list select' }
end

describe '/authors/:author' do
  before do
    visit author_path 'test'
  end

  specify { page.should have_selector 'header nav' }
  specify { page.should have_selector '.stackview-container' }
end
