class LogsController < ApplicationController
  before_action :set_cave, only: [:new, :create]

  def show
    @log = Log.find(params[:id])
  end

  def new
    @log = Log.new
    @log.build_log_cave_copy(cave: @cave)
    @log.log_location_copies.build
  end

  def create
    @log = Log.new(log_params.merge(user: current_user))
    logger.info(log_params)
    logger.info(@log)
    if @cave.present?
      @log.log_cave_copy.cave = @cave
    end

    if @log.save
      redirect_to(@log)
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def set_cave
    @cave = Cave.find(params[:cave_id]) if params[:cave_id]
  end

  def log_params
    params.require(:log).permit(
      :start_datetime,
      :end_datetime,
      :personal_comments,
      log_cave_copy_attributes: [:cave_id, :cave_title],
      log_location_copies_attributes: [:location_id]
    )
  end
end
