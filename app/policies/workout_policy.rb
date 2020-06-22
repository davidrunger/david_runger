# frozen_string_literal: true

class WorkoutPolicy < ApplicationPolicy
  class Scope < ::ApplicationPolicy::Scope
    def resolve
      @scope.where(user: @user).or(@scope.where(publicly_viewable: true))
    end
  end
end
