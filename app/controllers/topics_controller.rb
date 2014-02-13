class TopicsController < ApplicationController
  def index
    @topics = Topic.all.order record_count: :desc
  end

  def show
    @topics = Topic.all.order :record_count
    @active_topic = Topic.find_by_slug params[:id]
  end
end
