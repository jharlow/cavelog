class CavesController < ApplicationController
  def index
    @caves = if params[:q].present?
      caves = Cave.search_by_text_or_location(params[:q])
      Kaminari.paginate_array(caves).page(params[:page]).per(10)
    else
      Cave
        .page(params[:page])
        .per(10)
    end
  end

  def show
    @cave = Cave.find(params[:id])
    current_user_logs = @cave
      .logs
      .left_outer_joins(log_partner_connections: :partnership)
      .where("user_id = :user_id", { user_id: current_user.id })
      .distinct

    @cutoff_count = 4

    @user_logs_preview = current_user_logs
      .order(created_at: :desc)
      .take(@cutoff_count)
    @user_logs_count = current_user_logs.count

    current_user_tagged_logs = @cave
      .logs
      .left_outer_joins(log_partner_connections: :partnership)
      .where("partnerships.user1_id = :user_id OR partnerships.user2_id = :user_id", { user_id: current_user.id })
      .distinct

    @user_tagged_logs = current_user_tagged_logs
      .order(created_at: :desc)
      .take(@cutoff_count)
    @user_tagged_logs_count = current_user_tagged_logs.count

    # TODO: only public logs
    @cave_logs_preview = @cave.logs.take(@cutoff_count)
    @cave_logs_count = @cave.logs.count
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
    if @cave.update(cave_params)
      redirect_to(@cave)
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @cave = Cave.find(params[:id])
    @cave.destroy
    redirect_to(root_path, status: :see_other)
  end

  private

  def cave_params
    params.require(:cave).permit(:title, :description, :longitude, :latitude)
  end
end
