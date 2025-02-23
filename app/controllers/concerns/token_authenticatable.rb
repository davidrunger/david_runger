module TokenAuthenticatable
  extend ActiveSupport::Concern
  prepend Memoization

  class InvalidToken < StandardError ; end

  private

  memoize \
  def auth_token
    return nil if auth_token_secret.blank?

    AuthToken.find_by(secret: auth_token_secret)
  end

  memoize \
  def auth_token_secret
    auth_token_secret = params[:auth_token] || auth_token_in_header
    # For AuthTokensController requests, the top-level `auth_token` param might be a hash, which we
    # don't want here.
    auth_token_secret.is_a?(String) ? auth_token_secret : nil
  end

  memoize \
  def auth_token_in_header
    authorization_header = request.headers['Authorization']

    if authorization_header.present?
      match = authorization_header.match(/\ABearer\s+(.+)\z/)
      match&.captures&.first
    end
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
