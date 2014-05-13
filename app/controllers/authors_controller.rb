class AuthorsController < ApplicationController
  def index
    @authors = Contributor.authors.where('full_biography IS NOT NULL')
    @active_author = nil
  end

  def show
    @authors = Contributor.authors.where('full_biography IS NOT NULL')
    @active_author = Contributor.author_by_slug params[:id]
  end
end
