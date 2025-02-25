class SessionsController < ApplicationController
  include UrlBaseable

  skip_before_action :authenticate_user!, only: [:new]

  def new
    skip_authorization
    if user_signed_in?
      flash[:notice] = 'You are already logged in.'
      redirect_to(root_path)
    else
      @title = 'Log in'
      store_redirect_chain
      render :new
    end
  end
end
