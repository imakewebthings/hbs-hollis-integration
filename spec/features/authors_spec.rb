require 'spec_helper'

describe '/authors' do
  before do
    visit authors_path
  end

  specify { page.should have_selector '.search-list select' }
end

describe '/authors/:author' do
  let(:contributor) { create :contributor }

  before do
    visit author_path contributor.name_slug
  end

  specify { page.should have_selector 'header nav' }
  specify { page.should have_selector '.stackview-container' }
end
