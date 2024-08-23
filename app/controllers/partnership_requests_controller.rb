class PartnershipRequestsController < ApplicationController
  before_action :authenticate_user!

  def new
    @partnership_request = PartnershipRequest.new
  end

  def create
    @partnership_request = current_user.sent_partnership_requests.build(partnership_request_params)

    if @partnership_request.save
      flash[:notice] = "Partnership request sent successfully."
      redirect_to(user_path(@partnership_request.requested_to))
    else
      flash[:alert] = "Unable to send partnership request."
      redirect_to(user_path(partnership_request_params[:requested_to_id]))
    end
  end

  def accept
    @partnership_request = PartnershipRequest.find(params[:id])
    if @partnership_request.requested_to != current_user
      flash[:alert] = "Cannot accept partnership request which is not addressed to you."
    elsif @partnership_request.accepted == true
      flash[:alert] = "This partnership request has already been accepted."
    elsif @partnership_request.accept!
      flash[:notice] = "Partnership request accepted."
    else
      flash[:alert] = "Unable to accept partnership request."
    end

    redirect_to(user_path(@partnership_request.requested_by))
  end

  def destroy
    @partnership_request = PartnershipRequest.find(params[:id])
    if !@partnership_request.requested_to == current_user || !@partnership_request.requested_by == current_user
      flash[:notice] = "You cannot delete a request you are not involved with."
    elsif @partnership_request.accepted == true
      flash[:notice] = "This request has already been accepted."
    elsif @partnership_request.destroy
      flash[:notice] = "Partnership request removed."
    else
      flash[:alert] = "Unable to delete partnership request."
    end

    redirect_to(user_path(current_user))
  end

  private

  def partnership_request_params
    params.require(:partnership_request).permit(:requested_to_id)
  end
end
