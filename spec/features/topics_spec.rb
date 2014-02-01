require 'spec_helper'

describe '/topics' do
  before do
    visit topics_path
  end

  specify { page.should have_selector 'header.fat' }
  specify { page.should have_selector '.search-list select' }
end

describe '/topics/:topic' do
  before do
    visit topic_path 'test'
  end

  specify { page.should have_selector 'header nav' }
  specify { page.should have_selector '.stackview-container' }
end
