# frozen_string_literal: true

module TokenAuthenticatable
  extend ActiveSupport::Concern
  extend Memoist

  class BlankToken < StandardError ; end
  class InvalidToken < StandardError ; end

  private

  memoize \
  def auth_token
    AuthToken.find_by(secret: auth_token_param)
  end

  memoize \
  def auth_token_param
    params[:auth_token]
  end

  memoize \
  def auth_token_param_present?
    auth_token_param.present?
  end

  memoize \
  def auth_token_user
    auth_token&.user
  end

  def verify_valid_auth_token!
    if auth_token_param.blank?
      raise(BlankToken)
    end

    if auth_token.blank?
      raise(InvalidToken)
    end

    auth_token.update!(last_used_at: Time.current)
    true
  end
end
