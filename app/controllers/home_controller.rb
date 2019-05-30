# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user, only: [:index]

  def index
    @description = 'The personal website of web developer David Runger'
    render :index
  end
end
