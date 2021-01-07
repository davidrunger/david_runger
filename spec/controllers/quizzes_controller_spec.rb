# frozen_string_literal: true

RSpec.describe QuizzesController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: quiz.id }) }

    let(:quiz) { Quiz.first! }

    context 'when viewed by the owner of the quiz' do
      before { expect(controller.current_user).to eq(quiz.owner) }

      it 'says "You are the quiz owner!"' do
        get_show
        expect(response.body).to have_text('You are the quiz owner!')
      end
    end

    context 'when viewed by a user who is not the quiz owner' do
      before do
        sign_in(non_owner)
        expect(controller.current_user).not_to eq(quiz.owner)
      end

      let(:non_owner) { User.where.not(id: quiz.owner).first! }

      context 'when the user is not yet a quiz participant' do
        before { expect(quiz.participants).not_to include(non_owner) }

        it 'has a form to enter a display name and join the quiz' do
          get_show
          expect(response.body).to have_css('form input#display_name[type=text]')
        end
      end
    end
  end

  describe '#new' do
    subject(:get_new) { get(:new) }

    it 'renders a form to create a new quiz' do
      get_new
      expect(response.body).to have_css("form[action='#{quizzes_path}'] input[type=text]")
    end
  end

  describe '#create' do
    subject(:post_create) { post(:create, params: { quiz: { name: quiz_name } }) }

    let(:quiz_name) { 'My Great Quiz' }

    it 'creates a quiz with the posted name' do
      expect { post_create }.to change { user.reload.quizzes.size }.by(1)
      quiz = Quiz.order(:created_at).last!
      expect(quiz.name).to eq(quiz_name)
    end
  end
end
