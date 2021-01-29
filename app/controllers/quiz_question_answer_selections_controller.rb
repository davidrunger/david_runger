# frozen_string_literal: true

class QuizQuestionAnswerSelectionsController < ApplicationController
  def create
    authorize(QuizQuestionAnswerSelection, :create?)

    quiz_participation =
      current_user.
        quiz_participations.
        find_by!(quiz_id: Quiz.find(params[:quiz_id]).id)
    selection =
      QuizQuestionAnswerSelections::Create.run!(
        params: quiz_question_answer_selection_params,
        quiz_participation: quiz_participation,
      ).selection

    redirect_to(selection.quiz)
  end

  def update
    @quiz_question_answer_selection = policy_scope(QuizQuestionAnswerSelection).find(params[:id])
    authorize(@quiz_question_answer_selection, :update?)

    @quiz_question_answer_selection.update!(quiz_question_answer_selection_params)

    flash[:notice] = 'Answer updated!'
    redirect_to(@quiz_question_answer_selection.quiz)
  end

  private

  def quiz_question_answer_selection_params
    params.require(:quiz_question_answer_selection).permit(:answer_id)
  end
end
