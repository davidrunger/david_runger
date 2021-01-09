# frozen_string_literal: true

RSpec.describe QuestionUploadsController do
  before { sign_in(user) }

  let(:user) { users(:user) }
  let(:quiz) { user.quizzes.first! }

  describe '#new' do
    subject(:get_new) { get(:new, params: { quiz_id: quiz.id }) }

    it 'renders a form to upload quiz questions' do
      get_new
      expect(response.body).to have_css('form textarea[name=questions]')
    end
  end

  describe '#create' do
    subject(:post_create) { post(:create, params: { quiz_id: quiz.id, questions: questions_list }) }

    let(:questions_list) do
      <<~QUESTIONS_LIST
        What's your Hogwarts house?
        Gryffindor
        Hufflepuff
        - Ravenclaw
        Slytherin

        Do you think that smarter people are usually capable of deeper love?
        Yes
        - No
      QUESTIONS_LIST
    end

    it 'creates log entries' do
      expect {
        post_create
      }.to change {
        quiz.reload.questions.size
      }.by(2).and change {
        quiz.reload.question_answers.size
      }.by(6)

      expect(response).to redirect_to(quiz_path(quiz))
    end
  end
end
