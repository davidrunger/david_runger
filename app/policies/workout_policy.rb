# frozen_string_literal: true

class WorkoutPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @scope.where(user: @user).or(@scope.where(publicly_viewable: true))
    end
  end
end
