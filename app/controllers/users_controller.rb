class UsersController < ApplicationController
  before_filter :authenticate_admin_user!
  def approve
    @user = User.find_by_id params[:user_id]
    @user.approve
  end
end
