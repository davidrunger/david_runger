# frozen_string_literal: true

module TokenAuthorizable
  extend ActiveSupport::Concern

  class BlankToken < StandardError ; end
  class InvalidToken < StandardError ; end

  private

  def verify_valid_auth_token!
    auth_token_param = params[:auth_token]

    if auth_token_param.blank?
      raise(BlankToken)
    end

    auth_token = current_user.auth_tokens.find_by(secret: auth_token_param)
    if auth_token.blank?
      raise(InvalidToken)
    end

    auth_token.update!(last_used_at: Time.current)
    true
  end
end
