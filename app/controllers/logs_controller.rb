class LogsController < ApplicationController
  before_action :set_cave, only: [:new, :create]

  def show
    @log = Log.find(params[:id])
    @available_locations = available_locations(@log, @log.log_cave_copy.cave) if @log.log_cave_copy.cave.present?
  end

  def new
    @log = Log.new
    @log.build_log_cave_copy(cave: @cave)
  end

  def create
    @log = Log.new(log_params.merge(user: current_user))
    if @cave.present?
      @log.log_cave_copy.cave = @cave
    end

    if @log.save
      redirect_to(@log)
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def add_location
    @log = Log.find(params[:id])
    @location = Location.find(params[:location_id])
    @log_location_copy = LogLocationCopy.new(log: @log, location: @location, location_title: @location.title)
    if LogLocationCopy.find_by(log_id: @log.id, location_id: @location.id)
      flash[:alert] = "This location has already been logged on this log"
    elsif @log.log_location_copies << @log_location_copy
      flash[:notice] = "Location added successfully."
    else
      flash[:alert] = "Failed to add location."
    end

    redirect_to(log_path(@log))
  end

  def remove_location
    logger.info("here")
    @log = Log.find(params[:id])
    @location = Location.find(params[:location_id])
    @log_location_copy = LogLocationCopy.find_by(log_id: @log.id, location_id: @location.id)
    if !@log_location_copy.present?
      flash[:alert] = "Location has not been added to this log!"
    elsif @log_location_copy.destroy
      flash[:notice] = "Location removed successfully."
    else
      flash[:alert] = "Failed to remove location."
    end

    redirect_to(log_path(params[:id]))
  end

  private

  def available_locations(log, cave)
    used_location_ids = log.log_location_copies.pluck(:location_id)
    if cave.present?
      {
        subsystems: cave.subsystems.map do |subsystem|
          {subsystem: subsystem, locations: subsystem.locations.where.not(id: used_location_ids)}
        end,
        miscellaneous: cave.locations.where.not(id: used_location_ids)
      }
    end
  end

  def set_cave
    @cave = Cave.find(params[:cave_id]) if params[:cave_id]
  end

  def log_params
    params.require(:log).permit(
      :start_datetime,
      :end_datetime,
      :personal_comments,
      log_cave_copy_attributes: [:cave_id, :cave_title]
    )
  end
end
