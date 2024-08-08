class LocationsController < ApplicationController
  before_action :set_locatable

  def show
    logger.info(params)
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
  end

  def create
    @location = @locatable.locations.new(location_params)
    if @location.save
      redirect_to(@locatable.path)
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    if @location.update(location_params)
      redirect_to(@locatable.path)
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  private def set_locatable
    if params[:cave_id] && params[:subsystem_id]
      @locatable = Subsystem.find(params[:subsystem_id])
      @parent = @locatable.cave
    elsif params[:cave_id]
      @locatable = Cave.find(params[:cave_id])
    end
  end

  private def location_params
    params.require(:location).permit(:title, :description)
  end
end
