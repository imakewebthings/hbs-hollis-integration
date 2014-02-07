class AuthorsController < ApplicationController
  def index
    @authors = Contributor.authors
    @active_author = nil
  end

  def show
    @authors = Contributor.authors
    @active_author = Contributor.author_by_slug params[:id]
  end
end
