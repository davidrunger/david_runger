# frozen_string_literal: true

RSpec.describe Admin::QuizQuestionsController do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    describe '#show' do
      subject(:get_show) { get(:show, params: { id: quiz_question.id }) }

      let(:quiz_question) { QuizQuestion.first! }

      it 'responds with 200' do
        get_show
        expect(response.status).to eq(200)
      end
    end

    describe '#destroy' do
      subject(:delete_destroy) { delete(:destroy, params: { id: quiz_question.id }) }

      let(:quiz_question) { QuizQuestion.first! }

      it 'redirects to the quiz show page' do
        delete_destroy
        expect(response).to redirect_to(admin_quiz_path(quiz_question.quiz.id))
      end
    end
  end
end
