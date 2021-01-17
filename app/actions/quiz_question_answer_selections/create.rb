# frozen_string_literal: true

class QuizQuestionAnswerSelections::Create < ApplicationAction
  requires :quiz_participation, Shaped::Shape(QuizParticipation)
  requires :params, Shaped::Shape(ActionController::Parameters)

  returns :selection, QuizQuestionAnswerSelection, presence: true

  def execute
    result.selection = quiz_participation.quiz_question_answer_selections.create!(params)

    QuizzesChannel.broadcast_to(
      quiz_participation.quiz,
      new_answerer_name: quiz_participation.display_name,
    )
  end
end
