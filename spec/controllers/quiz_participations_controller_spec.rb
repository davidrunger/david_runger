# frozen_string_literal: true

RSpec.describe QuizParticipationsController do
  before { sign_in(user) }

  let(:user) { users(:user) }
  let(:quiz) { Quiz.first! }

  describe '#create' do
    subject(:post_create) { post(:create, params: { quiz_id: quiz.id, display_name: 'Al' }) }

    context 'when the user is not yet participating in the quiz' do
      before { user.quiz_participations.where(quiz: quiz).find_each(&:destroy!) }

      it 'creates a QuizParticipation for the user' do
        expect { post_create }.to change { user.reload.quiz_participations.size }.by(1)
      end
    end
  end
end
