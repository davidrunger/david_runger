# frozen_string_literal: true

RSpec.describe Admin::QuizQuestionAnswersController do
  let(:quiz_question_answer) { QuizQuestionAnswer.first! }

  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    describe '#show' do
      subject(:get_show) { get(:show, params: { id: quiz_question_answer.id }) }

      it 'responds with 200' do
        get_show
        expect(response.status).to eq(200)
      end
    end

    describe '#edit' do
      subject(:get_edit) { get(:edit, params: { id: quiz_question_answer.id }) }

      it 'responds with 200' do
        get_edit
        expect(response.status).to eq(200)
      end
    end
  end
end
