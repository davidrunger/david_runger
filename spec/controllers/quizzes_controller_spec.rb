RSpec.describe QuizzesController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    it 'explains that active quiz functionality has been removed' do
      get_index

      expect(response.body).
        to have_text('Active quiz functionality has been removed.')
    end

    it 'lists completed quizzes the user participated in or owns' do
      participated_quiz = user.quiz_participations.first!.quiz
      participated_quiz.update!(status: 'closed')
      owned_quiz = create(:quiz, owner: user, status: 'closed')
      other_quiz = create(:quiz, owner: users(:married_user), status: 'closed')

      get_index

      expect(response.body).to have_link(participated_quiz.name, href: quiz_path(participated_quiz))
      expect(response.body).to have_link(owned_quiz.name, href: quiz_path(owned_quiz))
      expect(response.body).not_to have_link(other_quiz.name, href: quiz_path(other_quiz))
    end
  end

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: quiz.hashid }) }

    let(:quiz) { user.quiz_participations.first!.quiz }

    before { quiz.update!(status: 'closed') }

    it 'renders the completed quiz results' do
      get_show

      expect(response.body).to have_text('Final results')
      expect(response.body).to have_text(quiz.questions.first!.content)
      expect(response.body).to have_text(quiz.participations.first!.display_name)
    end

    context 'when the quiz is not completed' do
      before { quiz.update!(status: 'active') }

      it 'raises an error' do
        expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the user did not participate in the quiz' do
      before do
        quiz.participations.where(participant: user).destroy_all
        expect(quiz.participants).not_to include(user)
      end

      it 'raises an error' do
        expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the user owns the quiz' do
      let(:quiz) { create(:quiz, owner: user, status: 'closed') }

      it 'renders the completed quiz results' do
        get_show

        expect(response.body).to have_text('Final results')
      end
    end
  end
end
