# frozen_string_literal: true

class AdminApplicationPolicy < ApplicationPolicy
  def index?
    # Generally, any logged-in AdminUser should be able to access an index action.
    # The records actually available in the index will be limited by the policy scope.
    @user.is_a?(AdminUser)
  end
end
