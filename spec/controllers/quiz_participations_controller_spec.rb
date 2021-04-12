# frozen_string_literal: true

RSpec.describe QuizParticipationsController do
  before { sign_in(user) }

  let(:user) { users(:user) }
  let(:quiz) { Quiz.first! }

  describe '#create' do
    subject(:post_create) do
      post(:create, params: { quiz_id: quiz.hashid, display_name: display_name })
    end

    context 'when the user is not yet participating in the quiz' do
      before { user.quiz_participations.where(quiz: quiz).find_each(&:destroy!) }

      context 'when the user submits a name' do
        let(:display_name) { 'Al' }

        it 'creates a QuizParticipation for the user' do
          expect { post_create }.to change { user.reload.quiz_participations.size }.by(1)
        end
      end

      context 'when the user does not submit a name' do
        let(:display_name) { '' }

        it 'does not create a QuizParticipation for the user' do
          expect { post_create }.not_to change { user.reload.quiz_participations.size }
        end

        it 'sets a flash message' do
          post_create
          expect(flash[:alert]).to eq("Display name can't be blank")
        end
      end
    end
  end
end
