# frozen_string_literal: true

module TokenAuthorizable
  extend ActiveSupport::Concern

  class BlankToken < StandardError ; end
  class IncorrectToken < StandardError ; end

  private

  def verify_valid_auth_token!
    auth_token_param = params[:auth_token]

    if auth_token_param.blank?
      raise(BlankToken)
    end

    if auth_token_param != current_user.auth_token
      raise(IncorrectToken)
    end

    true
  end
end
