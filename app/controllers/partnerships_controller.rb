class PartnershipsController < ApplicationController
  def show
  end

  def destroy
    @partnership = Partnership.find(params[:id])
    if @partnership.user1.id != current_user.id && @partnership.user2.id != current_user.id
      flash[:alert] = "Cannot delete parntership that you are not involved in"
    else
      other_user_id = (@partnership.user1.id == current_user.id) ? @partnership.user1.id : @partnership.user2.id
      @other_user = User.find(other_user_id)
      if @partnership.destroy
        flash[:notice] = "Partnership removed."
      else
        flash[:alert] = "Could not remove partnership."
      end

      redirect_to(user_path(@other_user), status: :see_other)
    end
  end
end
