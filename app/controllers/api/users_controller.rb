# frozen_string_literal: true

class Api::UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    authorize(@user, :update?)
    @user.update!(user_params)
    render json: @user
  end

  private

  def user_params
    params.require(:user).permit(:phone)
  end
end
