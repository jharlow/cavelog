class PartnershipsController < ApplicationController
  def show
  end

  def destroy
    @partnership = Partnership.find(params[:id])
    other_user_id = (@partnership.user1.id == current_user.id) ? @partnership.user1.id : @partnership.user2.id
    @other_user = User.find(other_user_id)
    @partnership.destroy
    redirect_to(user_path(@other_user), status: :see_other)
  end
end
