# frozen_string_literal: true

RSpec.describe QuizQuestionsController do
  before { sign_in(user) }

  describe '#update' do
    subject(:patch_update) do
      patch(
        :update,
        params: {
          id: quiz_question.id,
          quiz_question: {
            status: new_status,
          },
        },
      )
    end

    before { quiz_question.update!(status: initial_status) }

    let(:user) { quiz_question.quiz.owner }
    let(:quiz_question) { QuizQuestion.first! }
    let(:initial_status) { QuizQuestion::STATUSES.first }
    let(:new_status) { QuizQuestion::STATUSES.second }

    it 'updates the specified quiz question' do
      expect {
        patch_update
      }.to change {
        quiz_question.reload.status
      }.from(initial_status).to(new_status)
    end
  end
end
