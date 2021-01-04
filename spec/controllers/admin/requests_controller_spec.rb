# frozen_string_literal: true

RSpec.describe Admin::RequestsController do
  let(:admin_user) { admin_users(:admin_user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    context 'when logged in as an AdminUser' do
      before { sign_in(admin_user) }

      it 'responds with 200' do
        get_index
        expect(response.status).to eq(200)
      end
    end
  end
end
