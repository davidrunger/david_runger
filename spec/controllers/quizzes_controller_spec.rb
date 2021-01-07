# frozen_string_literal: true

RSpec.describe QuizzesController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: quiz.id }) }

    let(:quiz) { Quiz.first! }

    it 'renders the name of the quiz' do
      get_show
      expect(response.body).to have_text(quiz.name)
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
