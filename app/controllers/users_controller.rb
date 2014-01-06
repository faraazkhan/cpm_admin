class UsersController < ApplicationController
  def approve
    @user = User.find_by_id params[:user_id]
    @user.approve
  end
end
