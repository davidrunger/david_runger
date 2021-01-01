# frozen_string_literal: true

RSpec.describe Admin::AdminUsersController do
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

  describe '#edit' do
    subject(:get_edit) { get(:edit, params: { id: admin_user.id }) }

    context 'when logged in as an AdminUser' do
      before { sign_in(admin_user) }

      it 'responds with 200' do
        get_edit
        expect(response.status).to eq(200)
      end
    end
  end
end
