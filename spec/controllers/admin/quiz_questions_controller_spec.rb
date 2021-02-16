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
  end
end
