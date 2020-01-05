# frozen_string_literal: true

RSpec.describe Api::ItemsController do
  before { sign_in(user) }

  let(:store) { stores(:store) }
  let(:user) { store.user }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the item params are valid' do
      let(:valid_params) { {store_id: store.id, item: {name: 'Milk', store_id: store.id}} }
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response.status).to eq(201)
      end

      it 'creates that item for the store' do
        expect { post_create }.to change { store.reload.items.size }.by(1)
      end
    end
  end
end
