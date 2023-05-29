# frozen_string_literal: true

class QuizParticipationDecorator < Draper::Decorator
  include Memery

  delegate_all

  memoize \
  def correct_answer_count
    correct_answer_selections.length
  end
end
