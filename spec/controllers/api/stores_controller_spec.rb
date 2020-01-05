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
end
