class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:is_admin?)
  end

  def access_denied(exception)
    redirect_to admin_organizations_path, :alert => exception.message
  end
end
