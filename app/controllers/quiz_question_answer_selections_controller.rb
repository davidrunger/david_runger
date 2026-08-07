class QuizQuestionAnswerSelectionsController < ApplicationController
  def create
    authorize(QuizQuestionAnswerSelection, :create?)

    quiz = Quiz.find_by_hashid!(params.expect(:quiz_id))
    quiz_participation =
      current_user.
        quiz_participations.
        find_by!(quiz:)
    answer = current_question_answer(quiz)

    return head(:unprocessable_content) if answer.nil?

    begin
      selection =
        QuizQuestionAnswerSelections::Create.run!(
          answer:,
          quiz_participation:,
        ).selection

      redirect_to(selection.quiz)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      head :unprocessable_content
    end
  end

  def update
    quiz = Quiz.find_by_hashid!(params.expect(:quiz_id))
    quiz_participation = current_user.quiz_participations.find_by!(quiz:)
    @quiz_question_answer_selection =
      policy_scope(quiz_participation.quiz_question_answer_selections).find(params.expect(:id))
    authorize(@quiz_question_answer_selection, :update?)
    answer = current_question_answer(quiz)

    return head(:unprocessable_content) if answer.nil?

    begin
      @quiz_question_answer_selection.select_answer!(answer)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      return head(:unprocessable_content)
    end

    flash[:notice] = 'Answer updated!'
    redirect_to(@quiz_question_answer_selection.quiz)
  end

  private

  def quiz_question_answer_selection_params
    params.expect(quiz_question_answer_selection: [:answer_id])
  end

  def current_question_answer(quiz)
    quiz.current_question&.answers&.find_by(
      id: quiz_question_answer_selection_params[:answer_id],
    )
  end
end
