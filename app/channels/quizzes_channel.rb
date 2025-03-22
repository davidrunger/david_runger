class QuizzesChannel < ApplicationCable::Channel
  def subscribed
    quiz = Quiz.find_by_hashid!(params[:quiz_id])
    authorize!(quiz, :show?)
    stream_for(quiz)
  end
end
