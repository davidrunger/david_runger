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

  describe '#index' do
    subject(:get_index) { get(:index) }

    it 'reponds with a list of workouts' do
      get_index

      expect(response.parsed_body).to be_present
      expect(response.parsed_body.map(&:keys)).
        to all(include(*%w[created_at id publicly_viewable rep_totals time_in_seconds username]))
    end
  end
end
