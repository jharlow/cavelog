class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @partnership_request = current_user.has_pending_request_with_user?(@user) ? current_user
      .received_partnership_requests
      .find_by(requested_by: @user, accepted: false) : PartnershipRequest.new
    @current_user_pending_requests = current_user.received_partnership_requests.where(accepted: false)
    @current_user_sent_requests = current_user.sent_partnership_requests.where(accepted: false)
  end
end
