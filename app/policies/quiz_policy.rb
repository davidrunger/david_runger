# frozen_string_literal: true

class QuizPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @scope.where(owner: @user)
    end
  end

  def show?
    true
  end

  def update?
    @record.owner == @user
  end
end
