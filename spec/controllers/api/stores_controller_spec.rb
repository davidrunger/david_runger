# frozen_string_literal: true

RSpec.describe Api::StoresController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the store being created is invalid' do
      let(:invalid_params) { {store: {name: ''}} }
      let(:params) { invalid_params }

      it 'does not create a store' do
        expect { post_create }.not_to change(Store, :count)
      end

      it 'returns a 422 status code' do
        post_create
        expect(response.status).to eq(422)
      end
    end

    context 'when the store being created is valid' do
      let(:valid_params) { {store: {name: 'Walmart'}} }
      let(:params) { valid_params }

      it 'creates a store' do
        expect { post_create }.to change(Store, :count).by(1)
      end

      it 'returns a 201 status code' do
        post_create
        expect(response.status).to eq(201)
      end
    end
  end

  describe '#update' do
    subject(:patch_update) { patch(:update, params: params) }

    let(:store) { stores(:store) }
    let(:base_params) { {id: store.id} }

    context 'when the store is being updated with invalid params' do
      let(:invalid_params) { {store: {name: ''}} }
      let(:params) { base_params.merge(invalid_params) }

      it 'does not update the store' do
        expect { patch_update }.not_to change { store.reload.attributes }
      end

      it 'returns a 422 status code' do
        patch_update
        expect(response.status).to eq(422)
      end
    end

    context 'when the store is being updated with valid params' do
      let(:valid_params) { {store: {name: store.name + ' Changed'}} }
      let(:params) { base_params.merge(valid_params) }

      it 'updates the store' do
        expect { patch_update }.to change { store.reload.name }
      end

      it 'returns a 200 status code' do
        patch_update
        expect(response.status).to eq(200)
      end
    end
  end
end
