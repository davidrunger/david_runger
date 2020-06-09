# frozen_string_literal: true

RSpec.describe Admin::IpBlocksController do
  before { sign_in(admin_user) }

  let(:admin_user) { users(:admin) }

  describe '#create' do
    subject(:post_create) { post(:create, params: { ip_block: params }) }

    context 'when the params are valid' do
      let(:params) { valid_params }
      let(:valid_params) { { ip: ip } }
      let(:ip) { '888.321.456.789' }

      it 'creates an IpBlock' do
        expect { post_create }.to change { IpBlock.count }.by(1)
        expect(IpBlock.order(:created_at).last!.ip).to eq(ip)
      end

      it 'redirects to the admin IpBlocks index page' do
        post_create
        expect(response).to redirect_to(admin_ip_blocks_path)
      end
    end
  end
end
