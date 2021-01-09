# frozen_string_literal: true

class QuizQuestionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @scope.where(quiz: Quiz.where(owner: @user))
    end
  end

  def update?
    @record.quiz.owner == @user
  end
end
