class UsersController < ApplicationController
  def edit
    @user = User.find(params[:id])
    authorize(@user)
    render :edit
  end
end
