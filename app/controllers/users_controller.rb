# frozen_string_literal: true

class UsersController < ApplicationController
  using BlankParamsAsNil

  before_action :ensure_own_account

  def edit
    render :edit
  end

  def update
    if current_user.update(user_params)
      flash[:notice] = 'Updated successfully!'
      redirect_location = session.delete('redirect_to') || edit_user_path(current_user)
      redirect_to(redirect_location)
    else
      render :edit
    end
  end

  private

  def user_params
    params.
      require(:user).
      permit(:phone).
      blank_params_as_nil(%w[phone])
  end

  def ensure_own_account
    head :forbidden unless current_user.id.to_s == params['id']
  end
end
