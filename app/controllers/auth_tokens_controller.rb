# frozen_string_literal: true

class AuthTokensController < ApplicationController
  before_action :set_auth_token, only: %i[destroy update]

  def create
    authorize(AuthToken)
    AuthTokens::Create.run!(user: current_user)
    redirect_to(edit_user_path(current_user))
  end

  def destroy
    authorize(@auth_token)
    @auth_token.destroy!
    redirect_to(edit_user_path(current_user))
  end

  def update
    authorize(@auth_token)
    @auth_token.update!(auth_token_params)
    flash[:notice] = 'Updated auth token successfully!'
    redirect_to(edit_user_path(current_user))
  end

  private

  def auth_token_params
    params.require(:auth_token).permit(:name, :secret)
  end

  def set_auth_token
    @auth_token = current_user.auth_tokens.find(params[:id])
  end
end
