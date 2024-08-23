class LogPartnerConnectionsController < ApplicationController
  def create
    @log_partner_connection = LogPartnerConnection.new(log_partner_connections_params)
    @log = Log.find(params[:id])
    @log_partner_connection.log = @log
    if !@log
      flash[:alert] = "Associated log could not be found."
    elsif @log.user != current_user
      flash[:alert] = "You cannot add partners to a log you do not own."
    elsif params[:log_partner_connection][:partnership_id]
      @partnership = Partnership.find(params[:log_partner_connection][:partnership_id])
      if !@partnership
        # add create unassociated partner here
        flash[:alert] = "Associated partner could not be found."
      elsif !@partnership.includes_user?(current_user)
        flash[:alert] = "You cannot associate a partnership you are not a member of."
      elsif @log.log_partner_connections.where(partnership_id: @partnership.id).exists?
        flash[:alert] = "Partner has already been added to log."
      else
        @log_partner_connection.partner_name = @partnership.other_user_than(current_user).name_for(current_user)
        if @log_partner_connection.save
          flash[:notice] = "Added partner to log."
        else
          flash[:alert] = "Unable to process your request to associate partner with log."
        end
      end
    elsif @log_partner_connection.save
      flash[:notice] = "Added partner to log."
    else
      flash[:alert] = "Unable to process your request to associate partner with log."
    end

    respond_to do |format|
      format.turbo_stream {
        @log = Log.find(params[:id])
        @available_partners = current_user.partners.where.not(id: @log.log_partner_connections.pluck(:partnership_id))
        render(
          turbo_stream: [
            turbo_stream.replace(
              "log_partners_#{@log.id}",
              partial: "log_partner_connections/edit-form",
              locals: { log: @log, available_partners: @available_partners, current_user: current_user }
            ),
            turbo_stream.replace(
              "log_details_#{@log.id}",
              partial: "logs/details-section",
              locals: { log: @log, current_user: current_user }
            )
          ]
        )
      }
      format.html { redirect_to(edit_log_partner_connections_path(@log)) }
    end
  end

  def edit
    @log = Log.find(params[:id])
    @available_partners = current_user.partners.where.not(id: @log.log_partner_connections.pluck(:partnership_id))
    if @log.user != current_user
      flash[:alert] = "You cannot edit partners on a log you do not own."
      redirect_to(log_path(@log))
    end
  end

  def destroy
    @log = Log.find(params[:id])
    if @log.user != current_user
      flash[:alert] = "You cannot edit partners on a log you do not own."
      redirect_to(log_path(@log))
    else
      @log_partner_connection = LogPartnerConnection.find(params[:partner_id])
      if !@log_partner_connection
        flash[:alert] = "Connection between specified partner and log could not be found."
      elsif @log_partner_connection.destroy
        flash[:notice] = "Connection removed."
      else
        flash[:alert] = "Error occured removing this connection."
      end
    end

    respond_to do |format|
      format.turbo_stream {
        @log = Log.find(params[:id])
        @available_partners = current_user.partners.where.not(id: @log.log_partner_connections.pluck(:partnership_id))
        render(
          turbo_stream: [
            turbo_stream.replace(
              "log_partners_#{@log.id}",
              partial: "log_partner_connections/edit-form",
              locals: { log: @log, available_partners: @available_partners, current_user: current_user }
            ),
            turbo_stream.replace(
              "log_details_#{@log.id}",
              partial: "logs/details-section",
              locals: { log: @log, current_user: current_user }
            )
          ]
        )
      }
      format.html { redirect_to(edit_log_partner_connections_path(@log)) }
    end
  end

  private

  def log_partner_connections_params
    params.require(:log_partner_connection).permit(:id, :log_id, :partnership_id, :partner_name)
  end
end
