require 'spec_helper'

describe '/units' do
  before do
    visit units_path
  end

  specify { page.should have_selector 'header.fat' }
  specify { page.should have_selector '.search-list' }
end

describe '/units/:unit' do
  let(:contributor) { create :contributor }

  before do
    visit unit_path contributor.primary_unit_slug
  end

  specify { page.should have_selector 'header nav' }
  specify { page.should have_selector '.stackview-container' }
end
