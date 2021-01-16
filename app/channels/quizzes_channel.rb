# frozen_string_literal: true

class QuizzesChannel < ApplicationCable::Channel
  def subscribed
    quiz = Quiz.find(params[:quiz_id])
    authorize!(quiz, :show?)
    stream_for(quiz)
  end
end
