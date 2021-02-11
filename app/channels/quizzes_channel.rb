# frozen_string_literal: true

class QuizzesChannel < ApplicationCable::Channel
  def subscribed
    quiz = Quiz.find_by_hashid!(params[:quiz_id]) # rubocop:disable Rails/DynamicFindBy
    authorize!(quiz, :show?)
    stream_for(quiz)
  end
end
