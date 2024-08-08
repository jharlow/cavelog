class LogsController < ApplicationController
  def show
    @log = Log.find(params[:id])
  end

  def new
    @log = Log.new
    @cave = Cave.find(params[:cave_id])
  end

  def create
    @cave = Cave.find(params[:cave_id])
    @log = @cave.logs.new(log_params.merge(user: current_user))
    if @log.save
      redirect_to(@log)
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  private def log_params
    params.require(:log).permit(:personal_comments, :cave, :start_datetime, :end_datetime)
  end
end
