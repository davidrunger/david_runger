# frozen_string_literal: true

class QuizDecorator < Draper::Decorator
  extend Memoist

  delegate_all

  def current_user_participation
    h.current_user.quiz_participations.find_by(quiz_id: id)
  end

  memoize \
  def current_user_participation!
    h.current_user.quiz_participations.find_by!(quiz_id: id)
  end

  def current_user_is_participating?
    current_user_participation.present?
  end

  def owned_by_current_user?
    h.current_user == owner
  end

  memoize \
  def current_question
    ordered_questions.offset(current_question_number - 1).first
  end

  def current_question_current_user_answer_selection
    current_question.
      answer_selections.
      find_or_initialize_by(participation_id: current_user_participation!)
  end

  def participation_answered_current_question?(participation)
    current_question.answer_selections.exists?(participation_id: participation.id)
  end

  def participations_sorted_by_display_name
    participations.decorate.sort_by { |participation| participation.display_name.downcase }
  end

  memoize \
  def question_count
    questions.count
  end

  private

  def ordered_questions
    questions.order(:created_at)
  end
end
