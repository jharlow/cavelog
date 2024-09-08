class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @partnership_request = current_user.has_pending_request_with_user?(@user) ? current_user
      .received_partnership_requests
      .find_by(requested_by: @user, accepted: false) : PartnershipRequest.new
    @current_user_pending_requests = current_user.received_partnership_requests.where(accepted: false)
    @current_user_sent_requests = current_user.sent_partnership_requests.where(accepted: false)
    @cutoff_count = 4
    @user_logs_preview = @user.logs.take(@cutoff_count)
    @user_logs_count = @user.logs.count
    tagged_logs_query = @user.logs.left_outer_joins(log_partner_connections: :partnership).where(
      "partnerships.user1_id = :user_id OR partnerships.user2_id = :user_id",
      { user_id: current_user.id }
    )
    @user_tagged_logs_preview = tagged_logs_query.take(@cutoff_count)
    @user_tagged_logs_count = tagged_logs_query.count
  end
end
