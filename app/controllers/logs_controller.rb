class LogsController < ApplicationController
  def index
    user_id = params[:user_id]
    cave_id = params[:cave_id]
    location_id = params[:location_id]

    if cave_id.present?
      @cave = Cave.find(cave_id)
      @cave_query = "log_cave_copies.cave_id = :cave_id"
    end

    if location_id.present?
      @location = Location.find(location_id)
      @location_query = "log_location_copies.location_id = :location_id"
    end

    if user_id.present?
      @user = User.find(user_id)
      @tagged_option = params.has_key?(:tagged)
      @user_query = params.has_key?(:tagged) ? "partnerships.user1_id = :user_id OR partnerships.user2_id = :user_id" : "user_id = :user_id"
    end

    query = [
      user_id.present? ? @user_query : nil,
      location_id.present? ? @location_query : nil,
      cave_id.present? ? @cave_query : nil
    ].compact.join(" AND ")

    # TODO: or is public
    @logs = Log
      .left_outer_joins(log_partner_connections: :partnership)
      .left_outer_joins(:log_cave_copies)
      .left_outer_joins(:log_location_copies)
      .where(query, { user_id: user_id, cave_id: cave_id, location_id: location_id })
      .distinct
      .page(params[:page])
      .per(10)
  end

  def show
    @log = Log.find(params[:id])
    @locations_data = @log.locations_data
    @unconnected_caves = @log.unconnected_caves
    @unconnected_locations = @log.unconnected_locations
  end

  def new
    @log = Log.new
    if params[:cave_id]
      @cave = Cave.find(params[:cave_id])
    end
  end

  def create
    @log = Log.new(log_params.except(:cave_id))
    @log.user = current_user
    if log_params[:cave_id]
      @cave = Cave.find(log_params[:cave_id])
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
    elsif @log.update(log_params)
      redirect_to(log_path(@log))
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @log = Log.find(params[:id])
    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to delete this log.")
    else
      @log.destroy
      redirect_to(root_path, status: :see_other)
    end
  end

  private

  def log_params
    params.require(:log).permit(:start_datetime, :end_datetime, :personal_comments, :cave_id)
  end
end
