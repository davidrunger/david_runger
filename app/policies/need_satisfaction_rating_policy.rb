class NeedSatisfactionRatingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.need_satisfaction_ratings
    end
  end
end
