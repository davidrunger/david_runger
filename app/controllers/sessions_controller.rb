# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [:new]

  def new
    if user_signed_in?
      flash[:notice] = 'You are already logged in.'
      redirect_to(root_path)
    else
      @title = 'Log in'
      render :new
    end
  end
end
