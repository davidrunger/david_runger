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
    !QuizQuestion.where(id: unrevealed_quiz_questions).exists?(id: object)
  end

  private

  def unrevealed_quiz_questions
    quiz.questions.order(:created_at).offset(quiz.current_question_number)
  end

  def current_user_answer
    answers.joins(:selections).
      where(
        quiz_question_answer_selections: {
          participation_id: current_user_participation,
        },
      ).
      first
  end

  def current_user_participation
    quiz.participations.where(participant_id: h.current_user)
  end
end
