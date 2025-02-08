module TokenAuthenticatable
  extend ActiveSupport::Concern
  prepend Memoization

  class InvalidToken < StandardError ; end

  private

  memoize \
  def auth_token
    return nil if auth_token_param.blank?

    AuthToken.find_by(secret: auth_token_param)
  end

  memoize \
  def auth_token_param
    auth_token_param = params[:auth_token]
    # For AuthTokensController requests, the top-level `auth_token` param might be a hash, which we
    # don't want here.
    auth_token_param.is_a?(String) ? auth_token_param : nil
  end

  memoize \
  def current_or_auth_token_user
    current_user || auth_token_user
  end

  memoize \
  def auth_token_user
    auth_token&.user
  end

  def verify_valid_auth_token!
    if auth_token.blank?
      raise(InvalidToken)
    end

    auth_token.update!(last_used_at: Time.current)

    true
  end
end
