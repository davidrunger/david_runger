# frozen_string_literal: true

class QuizParticipationDecorator < Draper::Decorator
  extend Memoist

  delegate_all

  memoize \
  def correct_answer_count
    correct_answer_selections.size
  end
end
