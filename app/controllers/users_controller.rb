# frozen_string_literal: true

class UsersController < ApplicationController
  using BlankParamsAsNil

  def edit
    @user = User.find(params[:id])
    authorize(@user)
    render :edit
  end

  def update
    authorize(current_user)
    if current_user.update(user_params)
      flash[:notice] = 'Updated successfully!'
      redirect_location = session.delete('redirect_to') || edit_user_path(current_user)
      redirect_to(redirect_location)
    else
      flash[:alert] = "Please fix these problems: #{current_user.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  private

  def user_params
    params.
      require(:user).
      permit(:auth_token, :phone).
      blank_params_as_nil(%w[phone])
  end
end
