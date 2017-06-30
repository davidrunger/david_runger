class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    render :index
  end

  def new_home
    render :new_home
  end
end
