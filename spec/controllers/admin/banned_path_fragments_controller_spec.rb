# frozen_string_literal: true

RSpec.describe Admin::BannedPathFragmentsController do
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
      subject(:get_show) { get(:show, params: { id: banned_path_fragment.id }) }

      let(:banned_path_fragment) { BannedPathFragment.first! }

      it 'responds with 200' do
        get_show
        expect(response.status).to eq(200)
      end
    end
  end
end
