# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [:new]

  def new
    skip_authorization
    if user_signed_in?
      flash[:notice] = 'You are already logged in.'
      redirect_to(root_path)
    else
      @title = 'Log in'
      render :new
    end
  end

  private

  helper_method \
  def url_base
    @url_base ||=
      case Rails.env
      when 'development' then "http://#{request.host}:#{request.port}"
      else "https://#{request.host}"
      end
  end
end
