class LogsController < ApplicationController
  def new
    @log = Log.new
  end

  def create
    @log = Log.new(log_params.merge(user: current_user))
    if @log.save
      redirect_to @log
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def log_params
    params.require(:log).permit(:personal_comments, :cave)
  end
end
