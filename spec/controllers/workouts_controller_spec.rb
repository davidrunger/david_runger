# frozen_string_literal: true

RSpec.describe WorkoutsController do
  let(:user) { users(:user) }

  before { sign_in(user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    it 'responds with 200' do
      get_index
      expect(response.status).to eq(200)
    end

    it 'has a title including "Workout"' do
      get_index
      expect(response.body).to have_title(/\AWorkout - David Runger\z/)
    end
  end
end
