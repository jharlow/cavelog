class CavesController < ApplicationController
  before_action :set_paper_trail_whodunnit
  def index
    @caves = if params[:q].present?
      caves = Cave.search_by_text_or_location(params[:q])
      Kaminari.paginate_array(caves).page(params[:page]).per(10)
    else
      Cave
        .page(params[:page])
        .per(10)
    end

    if current_user
      @cutoff_count = 4
      @user_logs_preview = current_user.logs.take(@cutoff_count)
      @user_logs_count = current_user.logs.count

      @logs_user_tagged_in = Log.left_outer_joins(log_partner_connections: :partnership).where(
        "(partnerships.user1_id = :user_id OR partnerships.user2_id = :user_id) AND logs.user_id != :user_id",
        {user_id: current_user.id}
      )
    end
  end

  def show
    @cave = Cave.find(params[:id])
    @cutoff_count = 4

    if !current_user.nil?
      current_user_logs = @cave
        .logs
        .left_outer_joins(log_partner_connections: :partnership)
        .where("user_id = :user_id", {user_id: current_user.id})
        .distinct

      @user_logs_preview = current_user_logs
        .order(created_at: :desc)
        .take(@cutoff_count)
      @user_logs_count = current_user_logs.count

      current_user_tagged_logs = @cave
        .logs
        .left_outer_joins(log_partner_connections: :partnership)
        .where(
          "(partnerships.user1_id = :user_id OR partnerships.user2_id = :user_id) AND user_id != :user_id",
          {user_id: current_user.id}
        )
        .distinct

      @user_tagged_logs = current_user_tagged_logs
        .order(created_at: :desc)
        .take(@cutoff_count)
      @user_tagged_logs_count = current_user_tagged_logs.count
    end

    @cave_logs_preview = @cave.logs.take(@cutoff_count)
    @cave_logs_count = @cave.logs.count
  end

  def history
    @cave = Cave.find(params[:cave_id])
    @versions = @cave.versions
  end

  def new
    @cave = Cave.new
  end

  def create
    @cave = Cave.new(cave_params)
    if @cave.save
      redirect_to(@cave)
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def edit
    @cave = Cave.find(params[:id])
  end

  def update
    @cave = Cave.find(params[:id])
    if current_user.can_edit
      if @cave.update(cave_params)
        redirect_to(@cave)
      else
        render(:edit, status: :unprocessable_entity)
      end
    else
      flash[:alert] = "You must have created at least 5 logs to edit #{@cave.title}"
      redirect_to(@cave)
    end
  end

  def destroy
    @cave = Cave.find(params[:id])
    if current_user.can_delete
      @cave.destroy
      redirect_to(root_path, status: :see_other)
    else
      flash[:alert] = "You are not authorized to delete #{@cave.title}"
      redirect_to(@cave)
    end
  end

  private

  def cave_params
    params.require(:cave).permit(:title, :description, :longitude, :latitude)
  end
end
