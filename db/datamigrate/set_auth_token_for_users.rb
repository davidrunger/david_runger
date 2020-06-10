# frozen_string_literal: true

def set_auth_token_for_users
  # before_validation hook will set auth_token for the user if they don't have one already
  User.find_each(&:save!)
end
