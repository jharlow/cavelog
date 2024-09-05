class LocationsController < ApplicationController
  before_action :set_locatable

  def show
    @location = Location.find(params[:id])

    current_user_features_in_logs = @location
      .logs
      .left_outer_joins(log_partner_connections: :partnership)
      .where(
        "partnerships.user1_id = :user_id OR partnerships.user2_id = :user_id OR user_id = :user_id",
        { user_id: current_user.id }
      )
      .distinct

    @cutoff_count = 4

    @user_logs_preview = current_user_features_in_logs
      .order(created_at: :desc)
      .take(@cutoff_count)
    @user_logs_count = current_user_features_in_logs.count

    # TODO: only public logs
    @location_logs_preview = @location.logs.take(@cutoff_count)
    @location_logs_count = @location.logs.count
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

  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    redirect_to(@location.locatable.path, status: :see_other)
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
