class UsersController < ApplicationController
  before_action :ensure_own_account

  def edit
    render :edit
  end

  def update
    current_user.update!(user_params)
  end

  private

  def user_params
    params.require(:user).permit(:phone)
  end

  def ensure_own_account
    head :forbidden unless current_user.id.to_s == params['id']
  end
end
