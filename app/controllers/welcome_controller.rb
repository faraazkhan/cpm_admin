class WelcomeController < ApplicationController
  before_filter :authenticate_user

  def home
    if current_user.internal?
      @internal = true
      @clients = Client.all
    else
      @client = current_user.client
    end
  end
end
