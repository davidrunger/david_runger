# frozen_string_literal: true

class QuizQuestionAnswerDecorator < Draper::Decorator
  delegate_all

  def respondents_list
    answering_participations.pluck(:display_name).sort_by(&:downcase).join(', ')
  end
end
