class QuizQuestionAnswerSelectionsController < ApplicationController
  def create
    authorize(QuizQuestionAnswerSelection, :create?)

    # rubocop:disable Rails/DynamicFindBy
    quiz_participation =
      current_user.
        quiz_participations.
        find_by!(quiz_id: Quiz.find_by_hashid!(params[:quiz_id]).id)
    # rubocop:enable Rails/DynamicFindBy
    selection =
      QuizQuestionAnswerSelections::Create.run!(
        params: quiz_question_answer_selection_params,
        quiz_participation:,
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
    params.expect(quiz_question_answer_selection: [:answer_id])
  end
end
