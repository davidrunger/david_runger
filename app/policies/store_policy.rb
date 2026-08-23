class StorePolicy < ApplicationPolicy
  class Scope < ::ApplicationPolicy::Scope
    def resolve
      @scope.
        where(user: @user).
        or(@scope.where(user: @user.spouse, private: false))
    end
  end
end
