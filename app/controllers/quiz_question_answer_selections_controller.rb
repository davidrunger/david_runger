# frozen_string_literal: true

class QuizQuestionAnswerSelectionsController < ApplicationController
  def create
    authorize(QuizQuestionAnswerSelection, :create?)
    selection =
      current_user.
        quiz_participations.
        find_by!(quiz_id: Quiz.find(params[:quiz_id]).id).
        quiz_question_answer_selections.
        create!(quiz_question_answer_selection_params)
    redirect_to(selection.quiz)
  end

  private

  def quiz_question_answer_selection_params
    params.require(:quiz_question_answer_selection).permit(:answer_id)
  end
end
