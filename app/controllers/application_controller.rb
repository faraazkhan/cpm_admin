class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_user_and_client, :load_environment_settings
  CONFIG = {'APP_TITLE' => 'APJ Regional Global Delivery Capacity & Performance Management'}
  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:is_admin?)
  end


  def access_denied(exception)
    redirect_to access_denied_path, :alert => exception.message
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || welcome_home_path
  end

  def authenticate_user
    redirect_to new_user_session_path unless current_user
  end

  protected
  def user_for_paper_trail
    user_signed_in? ? current_user : 'Unknown user'
  end

  def set_user_and_client
    if current_user
      @user = current_user
      @clients = Client.order(:name)
      app_title = CONFIG['APP_TITLE']
      user_name = @user.name
      time = Time.now
      @panel_text = [app_title, user_name, time].join(' ')
      if current_user.is_client?
        @client = current_user.client
      else #if user is not client, they must be internal
        @client = Client.find_by_id session[:client_id] || @clients.first
        @internal = true
      end
    end
  end

  def load_environment_settings
    @page_title = EnvVar.app_title
  end
end
