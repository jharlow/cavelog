class LogsController < ApplicationController
  def show
    @log = Log.find(params[:id])
    @locations_data = @log.locations_data
    @unconnected_caves = @log.unconnected_caves
    @unconnected_locations = @log.unconnected_locations
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

    respond_to do |format|
      format.turbo_stream {
        render(
          turbo_stream: turbo_stream.replace(
            "edit_location_frame_#{params[:location_id]}",
            partial: "locations/attached-location-form",
            locals: {action: "Remove", path: remove_location_log_path(@log), location: @location}
          )
        )
      }
      format.html { redirect_to(log_path(@log)) }
    end
  end

  def remove_location
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

    respond_to do |format|
      format.turbo_stream {
        render(
          turbo_stream: turbo_stream.replace(
            "edit_location_frame_#{params[:location_id]}",
            partial: "locations/attached-location-form",
            locals: {action: "Add", path: add_location_log_path(@log), location: @location}
          )
        )
      }
      format.html { redirect_to(log_path(@log)) }
    end
  end

  def edit_cave_locations
    @log = Log.find(params[:id])
    @cave = @log.caves.where(id: params[:cave_id]).first
    @cave_locations_data = @log.locations_data[:caves].find { |cave| cave[:cave][:data].id == @cave.id }
    if !@cave.present? && @cave_locations_data.present?
      render(file: "#{Rails.root}/public/404.html", status: 404)
    end
  end

  def select_cave_to_add
    @log = Log.find(params[:id])
    @caves = params[:q].present? ? Cave.search(params[:q]).records : Cave.all
  end

  def add_cave
    @log = Log.find(params[:id])
    @cave = Cave.find(params[:cave_id])
    @log_cave_copy = LogCaveCopy.new(log: @log, cave: @cave, cave_title: @cave.title)
    if LogCaveCopy.find_by(log_id: @log.id, cave_id: @cave.id)
      flash[:alert] = "This cave has already been logged on this log"
    elsif @log.log_cave_copies << @log_cave_copy
      flash[:notice] = "Cave added successfully."
    else
      flash[:alert] = "Failed to add cave."
    end

    redirect_to(log_path(@log))
  end

  def remove_cave
    @log = Log.find(params[:id])
    @cave = Cave.find(params[:cave_id])
    @log_cave_copy = LogCaveCopy.find_by(log_id: @log.id, cave_id: @cave.id)
    if !@log_cave_copy.present?
      flash[:alert] = "Cave has not been added to this log!"
    elsif @log_cave_copy.destroy
      flash[:notice] = "Cave removed successfully."
    else
      flash[:alert] = "Failed to remove cave."
    end

    redirect_to(log_path(@log))
  end

  private

  def log_params
    params.require(:log).permit(:start_datetime, :end_datetime, :personal_comments)
  end
end
