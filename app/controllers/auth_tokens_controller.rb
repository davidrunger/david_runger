# frozen_string_literal: true

class AuthTokensController < ApplicationController
  using BlankParamsAsNil

  before_action :set_auth_token, only: %i[destroy update]

  def create
    authorize(AuthToken)
    AuthTokens::Create.new(user: current_user).run!
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
    redirect_to(edit_user_path(current_user))
  end

  private

  def auth_token_params
    params.
      require(:auth_token).
      permit(:name, :secret).
      blank_params_as_nil(%w[name secret])
  end

  def set_auth_token
    @auth_token = current_user.auth_tokens.find(params[:id])
  end
end
