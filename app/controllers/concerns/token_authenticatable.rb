module TokenAuthenticatable
  extend ActiveSupport::Concern
  prepend Memoization

  class InvalidToken < StandardError ; end

  module ClassMethods
    def allow_auth_token_authorization
      class_eval do
        def pundit_user
          current_or_auth_token_user
        end
      end
    end
  end

  private

  memoize \
  def auth_token_valid_for_action
    if auth_token_secret.present?
      auth_token = AuthToken.find_by(secret: auth_token_secret)

      if auth_token&.valid_for?(controller_action)
        auth_token.update!(last_used_at: Time.current)

        auth_token
      end
    end
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
      match = authorization_header.match(/\ABearer\s+(?<token>.+)\z/)
      match&.named_captures&.[]('token')
    end
  end

  memoize \
  def current_or_auth_token_user
    current_user || auth_token_user
  end

  memoize \
  def auth_token_user
    auth_token_valid_for_action&.user
  end

  def verify_valid_auth_token!
    if auth_token_valid_for_action.blank?
      raise(InvalidToken)
    end

    true
  end
end
