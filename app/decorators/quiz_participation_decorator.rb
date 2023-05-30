# frozen_string_literal: true

class QuizParticipationDecorator < Draper::Decorator
  prepend MemoWise

  delegate_all

  memo_wise \
  def correct_answer_count
    correct_answer_selections.length
  end
end
