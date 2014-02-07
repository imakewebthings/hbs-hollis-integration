class UnitsController < ApplicationController
  def index
    @units = Contributor.units
  end

  def show
    @units = Contributor.units
    @id = params[:id]
  end
end
