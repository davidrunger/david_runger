class QuizParticipationDecorator < Draper::Decorator
  prepend Memoization

  delegate_all

  memoize \
  def correct_answer_count
    correct_answer_selections.length
  end
end
