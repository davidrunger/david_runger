# frozen_string_literal: true

RSpec.describe QuizQuestionAnswerSelectionsController do
  before { sign_in(users(:user)) }

  describe '#create' do
    subject(:post_create) do
      post(
        :create,
        params: {
          quiz_id: quiz.hashid,
          quiz_question_answer_selection: {
            answer_id: quiz.question_answers.first!.id,
          },
        },
      )
    end

    let(:quiz) { Quiz.first! }

    it 'creates a QuizQuestionAnswerSelection' do
      expect { post_create }.to change { QuizQuestionAnswerSelection.count }.by(1)
    end
  end
end
