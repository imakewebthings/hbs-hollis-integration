class UnitsController < ApplicationController
  def index
    @units = Contributor.units
  end

  def show
    @units = Contributor.units
    @active_unit = @units.find_by_primary_unit_slug params[:id]
    @authors = Contributor.authors.where(
      primary_unit_slug: @active_unit.primary_unit_slug
    )
  end
end
