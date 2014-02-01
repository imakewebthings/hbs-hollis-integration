class AuthorsController < ApplicationController
  def index
  end

  def show
    @id = params[:id]
  end
end
