# frozen_string_literal: true

class AuthTokens::Create < ApplicationAction
  requires :user, User

  def execute
    user.auth_tokens.create!(secret: SecureRandom.uuid)
  end
end
