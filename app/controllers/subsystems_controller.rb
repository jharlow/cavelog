class SubsystemsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!, only: [:new, :create, :edit, :update]

  def show
    @subsystem = Subsystem.find(params[:id])
    if current_user
      subsystem_location_ids = @subsystem.locations.pluck(:id)
      @visited = @subsystem
        .cave
        .logs
        .left_outer_joins(log_partner_connections: :partnership)
        .left_outer_joins(:log_location_copies)
        .where(
          "(partnerships.user1_id = :user_id OR partnerships.user2_id = :user_id) AND log_location_copies.location_id IN (:location_ids)",
          {user_id: current_user.id, location_ids: subsystem_location_ids}
        )
        .distinct
    end
  end

  def new
    @subsystem = Subsystem.new
    @cave = Cave.find(params[:cave_id])
  end

  def create
    @cave = Cave.find(params[:cave_id])
    @subsystem = @cave.subsystems.new(subsystem_params)
    if @subsystem.save
      redirect_to(cave_subsystem_url(@cave, @subsystem))
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def edit
    @subsystem = Subsystem.find(params[:id])
  end

  def update
    @subsystem = Subsystem.find(params[:id])

    if current_user.can_edit
      if @subsystem.update(subsystem_params)
        redirect_to(cave_subsystem_url(@subsystem.cave, @subsystem))
      else
        render(:edit, status: :unprocessable_entity)
      end
    else
      flash[:alert] = "You must have created at least 5 logs to edit #{@subsystem.title}"
      redirect_to(@subsystem.path)
    end
  end

  def destroy
    @subsystem = Subsystem.find(params[:id])
    if current_user.can_delete
      @subsystem.destroy
      redirect_to(cave_path(@subsystem.cave), status: :see_other)
    else
      flash[:alert] = "You are not authorized to delete #{@subsystem.title}"
      redirect_to(@subsystem.path)
    end
  end

  private def subsystem_params
    params.require(:subsystem).permit(:title, :description, :cave)
  end
end
