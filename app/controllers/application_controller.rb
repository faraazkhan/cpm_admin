class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:is_admin?)
  end

  def access_denied(exception)
    redirect_to access_denied_path, :alert => exception.message
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_admin?
        admin_dashboard_path
      else
        root_path
      end
  end
end
