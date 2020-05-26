# frozen_string_literal: true

RSpec.describe Api::WorkoutsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the item params are valid' do
      let(:valid_params) do
        { workout: { time_in_seconds: 600, rep_totals: { chinups: 2, pushups: 9 } } }
      end
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response.status).to eq(201)
      end

      it 'creates a workout for the user' do
        expect { post_create }.to change { user.reload.workouts.size }.by(1)
      end
    end
  end
end
