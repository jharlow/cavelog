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

  def edit
    @log = Log.find(params[:id])
    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to edit this log.")
    end
  end

  def update
    @log = Log.find(params[:id])
    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to access this page.")
    end

    if @log.update(log_params)
      redirect_to(log_path(@log))
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @log = Log.find(params[:id])
    @log.destroy
    redirect_to(root_path, status: :see_other)
  end

  private

  def log_params
    params.require(:log).permit(:start_datetime, :end_datetime, :personal_comments)
  end
end
