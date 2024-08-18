class LogPartnerConnectionsController < ApplicationController
  def create
    logger.info(params)
    @log = Log.find(params[:id])
    if !@log
      flash[:alert] = "Associated log could not be found."
    elsif @log.user != current_user
      flash[:alert] = "You cannot add partners to a log you do not own."
    else
      @partnership = Partnership.find(params[:log_partner_connections][:partnership_id])
      if !@partnership
        flash[:alert] = "Associated partner could not be found."
      elsif !@partnership.includes_user?(current_user)
        flash[:alert] = "You cannot associate a partnership you are not a member of."
      else
        @log_partner_connection = LogPartnerConnection.new(log_partner_connections_params)
        @log_partner_connection.log = @log
        @log_partner_connection.partner_name = @partnership.other_user_than(current_user).name_for(current_user)
        if @log_partner_connection.save
          flash[:notice] = "Added partner to log."
        else
          flash[:alert] = "Unable to process your request to associate partner with log."
        end
      end
    end

    redirect_to(log_path(@log))
  end

  def edit
    @log = Log.find(params[:id])
  end

  def destroy
  end

  private

  def log_partner_connections_params
    params.require(:log_partner_connections).permit(:log_id, :partnership_id, :partner_name)
  end
end
