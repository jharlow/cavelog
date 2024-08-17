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
    logger.info(params)
    @partnership_request = PartnershipRequest.find(params[:id])
    logger.info(@partnership_request)

    if @partnership_request.requested_to == current_user &&
        @partnership_request.accepted == false &&
        @partnership_request.accept!
      flash[:notice] = "Partnership request accepted."
    else
      flash[:alert] = "Unable to accept partnership request."
    end

    redirect_to(user_path(@partnership_request.requested_by))
  end

  private

  def partnership_request_params
    params.require(:partnership_request).permit(:requested_to_id)
  end
end
