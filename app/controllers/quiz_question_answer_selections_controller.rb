# frozen_string_literal: true

class QuizQuestionAnswerSelectionsController < ApplicationController
  def create
    authorize(QuizQuestionAnswerSelection, :create?)

    quiz_participation =
      current_user.
        quiz_participations.
        find_by!(quiz_id: Quiz.find(params[:quiz_id]).id)
    selection =
      QuizQuestionAnswerSelections::Create.new(
        params: quiz_question_answer_selection_params,
        quiz_participation: quiz_participation,
      ).run!.selection

    redirect_to(selection.quiz)
  end

  private

  def quiz_question_answer_selection_params
    params.require(:quiz_question_answer_selection).permit(:answer_id)
  end
end
