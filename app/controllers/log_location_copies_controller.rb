class LogLocationCopiesController < ApplicationController
  def create
    @log = Log.find(params[:id])
    location_id = params[:log_location_copy][:location_id]
    location = Location.find(location_id)
    @log_location_copy = LogLocationCopy.new(log: @log, location: location, location_title: location.title)

    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to edit locations on this log.")
    elsif !location
      flash[:alert] = "That location doesn't seem to exist!"
    elsif LogLocationCopy.find_by(log_id: @log.id, location_id: location.id)
      flash[:alert] = "This location has already been logged on this log"
    elsif @log_location_copy.save
      flash[:notice] = "Location added successfully."
    else
      flash[:alert] = "Failed to add location."
    end

    respond_to do |format|
      format.turbo_stream { rerender_location_relevant_partials(@log, location, @log_location_copy) }
      format.html { redirect_to(edit_cave_log_location_copies(@log, location.get_cave)) }
    end
  end

  def edit
    @log = Log.find(params[:id])
    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to edit locations on this log.")
    end

    @cave = @log.caves.where(id: params[:cave_id]).first
    if @cave.present?
      @cave_locations_data = @log.locations_data[:caves].find { |cave| cave[:cave][:data].id == @cave.id }
    else
      @unconnected_locations = @log.unconnected_locations
    end
  end

  def destroy
    @log = Log.find(params[:id])
    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to edit locations on this log.")
    else
      @log_location_copy = LogLocationCopy.find(params[:location_id])
      location = @log_location_copy.location
      if !@log_location_copy.present?
        flash[:alert] = "Location has not been added to this log!"
      elsif @log_location_copy.destroy
        flash[:notice] = "Location removed successfully."
      else
        flash[:alert] = "Failed to remove location."
      end
    end

    respond_to do |format|
      format.turbo_stream {
        if location
          # only needs location button to switch from remove to add or vice-versa
          rerender_location_relevant_partials(@log, location, nil)
        else
          # needs whole form because entire location needs to be removed
          rerender_misc_edit_form(@log)
        end
      }
      format.html { redirect_to(edit_cave_log_location_copies(@log, location.get_cave)) }
    end
  end

  private

  def rerender_misc_edit_form(log)
    locals = {unconnected_locations: log.unconnected_locations, log: log, cave: nil, cave_locations_data: nil}
    render(
      turbo_stream: turbo_stream.replace(
        "log_locations_cave_misc",
        partial: "log_location_copies/edit-form",
        locals: locals
      )
    )
  end

  def rerender_location_relevant_partials(log, location, log_location_copy)
    render(
      turbo_stream: turbo_stream.replace(
        "edit_log_#{log.id}_location_#{location.id}",
        partial: "log_location_copies/attached-location-form",
        locals: {log: log, log_location_copy: log_location_copy, location: location}
      )
    )
  end

  def log_location_copy_params
    params.require(:log_location_copy).permit(:id, :log_id, :location_id, :location_title)
  end
end
