class QuizQuestionAnswerSelections::Create < ApplicationAction
  requires :quiz_participation, QuizParticipation
  requires :answer, QuizQuestionAnswer

  returns :selection, QuizQuestionAnswerSelection, presence: true

  def execute
    selection = quiz_participation.quiz_question_answer_selections.build
    selection.select_answer!(answer)
    result.selection = selection

    QuizzesChannel.broadcast_to(
      quiz_participation.quiz,
      new_answerer_name: quiz_participation.display_name,
    )
  end
end
