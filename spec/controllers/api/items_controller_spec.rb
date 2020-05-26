# frozen_string_literal: true

RSpec.describe Api::ItemsController do
  before { sign_in(user) }

  let(:store) { stores(:store) }
  let(:user) { store.user }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the item params are valid' do
      let(:valid_params) { { store_id: store.id, item: { name: 'Milk', store_id: store.id } } }
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

  describe '#update' do
    subject(:patch_update) { patch(:update, params: params) }

    let(:item) { items(:item) }
    let(:base_params) { { id: item.id } }

    context 'when attempting to update the item of another user' do
      let(:owning_user) { item.store.user }
      let(:user) { User.where.not(id: owning_user).first! }
      let(:params) { base_params.merge(item: { name: item.name + ' Changed' }) }

      it 'does not update the item' do
        expect { patch_update }.not_to change { item.reload.attributes }
      end

      it 'returns a 404 status code' do
        patch_update
        expect(response.status).to eq(404)
      end
    end

    context 'when the item is being updated with invalid params' do
      let(:invalid_params) { { item: { name: '' } } }
      let(:params) { base_params.merge(invalid_params) }

      it 'does not update the item' do
        expect { patch_update }.not_to change { item.reload.attributes }
      end

      it 'returns a 422 status code' do
        patch_update
        expect(response.status).to eq(422)
      end
    end

    context 'when the item is being updated with valid params' do
      let(:valid_params) { { item: { name: item.name + ' Changed' } } }
      let(:params) { base_params.merge(valid_params) }

      it 'updates the item' do
        expect { patch_update }.to change { item.reload.name }
      end

      it 'returns a 200 status code' do
        patch_update
        expect(response.status).to eq(200)
      end
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy, params: { id: item.id }) }

    let(:item) { items(:item) }

    context 'when attempting to destroy the item of another user' do
      let(:owning_user) { item.store.user }
      let(:user) { User.where.not(id: owning_user).first! }

      it 'does not destroy the item' do
        expect { delete_destroy }.not_to change { item.reload.persisted? }
      end

      it 'returns a 404 status code' do
        delete_destroy
        expect(response.status).to eq(404)
      end
    end

    context "when attempting to destroy one's own item" do
      let(:user) { item.store.user }

      it 'destroys the item' do
        expect { delete_destroy }.to change { Item.find_by(id: item.id) }.from(Item).to(nil)
      end

      it 'returns a 204 status code' do
        delete_destroy
        expect(response.status).to eq(204)
      end
    end
  end
end
