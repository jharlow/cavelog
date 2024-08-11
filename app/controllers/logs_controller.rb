class LogsController < ApplicationController
  def show
    @log = Log.find(params[:id])
    @locations_data = locations_data(@log)
    logger.info(@locations_data)
  end

  def new
    @log = Log.new
  end

  def create
    @log = Log.new(log_params)
    @log.user = current_user

    if params[:cave_id].present?
      @cave = Cave.find(params[:cave_id])
      if @cave.present?
        @log_cave_copy = LogCaveCopy.new(cave: @cave, cave_title: @cave.title)
        @log.log_cave_copies << @log_cave_copy
      end
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

  def locations_data(log)
    log_cave_copies_cave_ids = log.log_cave_copies.pluck(:cave_id)
    caves = Cave.where(id: log_cave_copies_cave_ids).map do |cave|
      cave_locations_data(cave, log)
    end

    { caves: caves }
  end

  def cave_locations_data(cave, log)
    cave_locations_data = locations_data_for_locatable(cave, log)
    subsystem_locations_data = cave.subsystems.map do |subsystem|
      locations_data_for_locatable(subsystem, log)
    end

    locations_visited_count = cave_locations_data[:locations_visited].length + subsystem_locations_data.sum { |ss|
      ss[:locations_visited].length
    }

    { cave: cave_locations_data, subsystems: subsystem_locations_data, locations_visited_count: locations_visited_count }
  end

  def locations_data_for_locatable(locatable, log)
    log_location_copies_location_ids = log.log_location_copies.pluck(:location_id)
    {
      data: locatable,
      locations_visited: locatable.locations.where(id: log_location_copies_location_ids),
      locations_not_visited: locatable.locations.where.not(id: log_location_copies_location_ids)
    }
  end

  def log_params
    params.require(:log).permit(:start_datetime, :end_datetime, :personal_comments)
  end
end
