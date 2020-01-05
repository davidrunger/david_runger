# frozen_string_literal: true

RSpec.describe Api::StoresController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    context 'when the store being created is invalid' do
      let(:invalid_params) { {store: {name: ''}} }

      it 'returns a 422 status code' do
        post(:create, params: invalid_params)
        expect(response.status).to eq(422)
      end
    end

    context 'when the store being created is valid' do
      let(:valid_params) { {store: {name: 'Walmart'}} }

      it 'returns a 201 status code' do
        post(:create, params: valid_params)
        expect(response.status).to eq(201)
      end
    end
  end
end
