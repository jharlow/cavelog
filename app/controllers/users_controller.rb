class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    if !params[:id].present?
      @user = current_user
    else
      @user = User.find(params[:id])
      @partnership_request = current_user.has_pending_request_with_user?(@user) ? current_user
        .received_partnership_requests
        .find_by(requested_by: @user) : PartnershipRequest.new
    end
  end
end
