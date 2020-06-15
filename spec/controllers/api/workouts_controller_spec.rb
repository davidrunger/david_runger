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

  describe '#update' do
    subject(:patch_update) { patch(:update, params: params) }

    let(:workout) { workouts(:workout) }

    context 'when the params are valid' do
      let(:valid_params) do
        { id: workout.id, workout: { publicly_viewable: !workout.publicly_viewable } }
      end
      let(:params) { valid_params }

      it 'returns a 200 status code' do
        patch_update
        expect(response.status).to eq(200)
      end

      it 'updates the workout' do
        expect { patch_update }.
          to change { workout.reload.publicly_viewable }.
          to(params.dig(:workout, :publicly_viewable))
      end

      it 'responds with the workout as JSON' do
        patch_update
        user.reload

        expect(response.parsed_body.keys).to include(*%w[
          created_at
          id
          publicly_viewable
          rep_totals
          time_in_seconds
          username
        ])
      end
    end
  end
end
