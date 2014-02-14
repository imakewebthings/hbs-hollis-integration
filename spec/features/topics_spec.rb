require 'spec_helper'

describe '/topics' do
  before do
    visit topics_path
  end

  specify { page.should have_selector 'header.fat' }
  specify { page.should have_selector '.search-list select' }
end

describe '/topics/:topic' do
  let (:topic) { create :topic }

  before do
    visit topic_path topic.slug
  end

  specify { page.should have_selector 'header nav' }
  specify { page.should have_selector '.stackview-container' }
end
