# frozen_string_literal: true

RSpec.describe QuizParticipationsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create, params: { quiz_id: Quiz.first!.id, display_name: 'Al' }) }

    it 'creates an auth token for the user' do
      expect { post_create }.to change { user.reload.quiz_participations.size }.by(1)
    end
  end
end
