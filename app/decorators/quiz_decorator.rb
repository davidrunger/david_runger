class QuizDecorator < Draper::Decorator
  prepend Memoization

  delegate_all

  memoize \
  def current_user_participation!
    h.current_user_participation.presence!
  end

  def current_user_is_participating?
    h.current_user_participation.present?
  end

  def owned_by_current_user?
    h.current_user == owner
  end

  def current_question_current_user_answer_selection
    current_question.
      answer_selections.
      find_or_initialize_by(participation_id: current_user_participation!)
  end

  def participation_answered_current_question?(participation)
    current_question.answer_selections.any? do |selection|
      selection.participation_id == participation.id
    end
  end

  def participations_sorted_by_score
    participations.
      includes(:correct_answer_selections).
      decorate.
      sort_by do |participation|
        # list from high score to low score, then use name to sort ties
        # rubocop:disable Style/YodaExpression
        [-1 * participation.correct_answer_count, participation.display_name.downcase]
        # rubocop:enable Style/YodaExpression
      end
  end

  memoize \
  def question_count
    questions.count
  end
end
