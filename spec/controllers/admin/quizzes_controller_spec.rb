# frozen_string_literal: true

RSpec.describe Admin::QuizzesController do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    describe '#index' do
      subject(:get_index) { get(:index) }

      it 'responds with 200' do
        get_index
        expect(response.status).to eq(200)
      end
    end

    describe '#show' do
      subject(:get_show) { get(:show, params: { id: quiz.id }) }

      let(:quiz) { Quiz.first! }

      it 'responds with 200' do
        get_show
        expect(response.status).to eq(200)
      end
    end
  end
end
