# frozen_string_literal: true

class UsersController < ApplicationController
  def edit
    @user = User.find(params[:id])
    authorize(@user)
    render :edit
  end
end
