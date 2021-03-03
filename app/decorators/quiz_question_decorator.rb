# frozen_string_literal: true

class QuizQuestionDecorator < Draper::Decorator
  delegate_all

  def answer_correctness_mark
    return '' if current_user_answer.blank? || open?

    if current_user_answer.is_correct?
      h.tag.span('✓', class: 'green')
    else
      h.tag.span('×', class: 'red')
    end
  end

  def revealed?
    created_at <= quiz.current_question.created_at
  end

  private

  def current_user_answer
    current_user_answer_selection&.answer
  end

  def current_user_answer_selection
    answer_selections.find do |selection|
      selection.participation_id == h.current_user_participation.id
    end
  end
end
