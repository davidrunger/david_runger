class HomeController < ApplicationController
  def index
    if user_signed_in?
      render :index
    else
      redirect_to user_google_oauth2_omniauth_authorize_path
    end
  end
end
