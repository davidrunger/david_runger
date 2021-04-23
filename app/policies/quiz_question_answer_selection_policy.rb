# frozen_string_literal: true

class QuizQuestionAnswerSelectionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @scope.joins(:participation).where(quiz_participations: { participant_id: @user })
    end
  end

  private

  def own_record?
    @record.participant == @user
  end
end
