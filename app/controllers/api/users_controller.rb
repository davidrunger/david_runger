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
    user_params = params.require(:user).permit(:phone)
    user_params.each do |key, value|
      case key
      when 'phone'
        phone = value.gsub(/[^[:digit:]]/, '')
        phone = "1#{phone}" if phone.size == 10
        user_params[key] = phone
      end
    end
  end
end
