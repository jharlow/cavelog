class LocationsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :set_locatable

  def show
    @location = Location.find(params[:id])

    @cutoff_count = 4

    if current_user
      current_user_logs = @location
        .logs
        .left_outer_joins(log_partner_connections: :partnership)
        .where("user_id = :user_id", {user_id: current_user.id})
        .distinct

      @user_logs_preview = current_user_logs
        .order(created_at: :desc)
        .take(@cutoff_count)
      @user_logs_count = current_user_logs.count

      current_user_tagged_logs = @location
        .logs
        .left_outer_joins(log_partner_connections: :partnership)
        .where(
          "partnerships.user1_id = :user_id OR partnerships.user2_id = :user_id AND user_id != :user_id",
          {user_id: current_user.id}
        )
        .distinct

      @user_tagged_logs = current_user_tagged_logs
        .order(created_at: :desc)
        .take(@cutoff_count)
      @user_tagged_logs_count = current_user_tagged_logs.count
    end

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
    if current_user.can_edit
      if @location.update(location_params.except(:subsystem_id).merge(locatable: locatable))
        redirect_to(@location.path)
      else
        render(:edit, status: :unprocessable_entity)
      end
    else
      flash[:alert] = "You must have created at least 5 logs to edit #{@location.title}"
      redirect_to(@location.path)
    end
  end

  def destroy
    @location = Location.find(params[:id])

    if current_user.can_delete
      @location.destroy
      redirect_to(@location.locatable.path, status: :see_other)
    else
      flash[:alert] = "You are not authorized to delete #{@location.title}"
      redirect_to(@location.path)
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
