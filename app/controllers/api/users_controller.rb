# frozen_string_literal: true

class Api::UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    authorize(@user)
    @user.update!(user_params)
    render json: @user
  end

  private

  def user_params
    user_params = params.require(:user).permit(preferences: {})
    user_params.each do |key, value|
      case key # :nocov-else: can't be anything but preferences bc that is only param permitted
      when 'preferences'
        user_params[key] = current_user.preferences.merge(value)
      end
    end
  end
end
