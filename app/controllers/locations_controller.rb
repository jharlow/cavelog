class LocationsController < ApplicationController
  before_action :set_locatable

  def show
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
  end

  def create
    is_cave = (location_params[:subsystem_id] != "")
    locatable = is_cave ? Subsystem.find(location_params[:subsystem_id]) : Cave.find(params[:cave_id])
    @location = locatable.locations.new(location_params.except(:subsystem_id))
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
    logger.info(params)
    @location = Location.find(params[:id])
    is_cave = (location_params[:subsystem_id] != "")
    locatable = is_cave ? Subsystem.find(location_params[:subsystem_id]) : Cave.find(params[:cave_id])
    if @location.update(location_params.except(:subsystem_id).merge(locatable: locatable))
      redirect_to(@location.path)
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  def set_locatable
    if params[:cave_id] && params[:subsystem_id]
      @locatable = Subsystem.find(params[:subsystem_id])
      @parent = @locatable.cave
    elsif params[:cave_id]
      @locatable = Cave.find(params[:cave_id])
    end
  end

  def location_params
    params.require(:location).permit(:title, :description, :subsystem_id)
  end
end
