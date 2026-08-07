RSpec.describe QuestionUploadsController do
  before { sign_in(user) }

  let(:user) { users(:married_user) }
  let(:quiz) { user.quizzes.first! }

  describe '#new' do
    subject(:get_new) { get(:new, params: { quiz_id: quiz.hashid }) }

    it 'renders a form to upload quiz questions' do
      get_new
      expect(response.body).to have_css('form textarea[name=questions]')
    end

    it 'has instructions about how to format the questions (and an example)' do
      get_new
      expect(response.body).to have_text(/Instructions.*separate line.*Example.*Which is biggest/m)
    end
  end

  describe '#create' do
    subject(:post_create) do
      post(:create, params: { quiz_id: quiz.hashid, questions: questions_list })
    end

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

    specify 'an upload can contain at most 500 questions' do
      expect(QuizQuestions::CreateFromList::MAX_QUESTIONS).to eq(500)
    end

    specify 'an upload can contain at most 5,000 answers' do
      expect(QuizQuestions::CreateFromList::MAX_ANSWERS).to eq(5_000)
    end

    it 'creates questions and answers' do
      expect {
        post_create
      }.to change {
        quiz.reload.questions.size
      }.by(2).and change {
        quiz.reload.question_answers.size
      }.by(6)

      expect(response).to redirect_to(quiz_path(quiz))
    end

    context 'when one of the questions being uploaded does not have an answer marked correct' do
      let(:questions_list) do
        <<~QUESTIONS_LIST
          Which is currently farther from the sun?
          Neptune
          -Pluto

          Do you think that smarter people are usually capable of deeper love?
          Yes
          No
        QUESTIONS_LIST
      end

      it 'renders the new form with an error message' do
        post_create
        expect(response.body).to have_css('form textarea[name="questions"]')
        expect(response.body).to have_flash_message(<<~TEXT.squish, type: :alert)
          Wrong number of correct answers for question 'Do you think that smarter people are usually
          capable of deeper love?'!
        TEXT
      end
    end

    context 'when the upload contains too many questions' do
      before { stub_const('QuizQuestions::CreateFromList::MAX_QUESTIONS', 2) }

      let(:questions_list) do
        <<~QUESTIONS_LIST
          Question one?
          - Yes
          No

          Question two?
          - Yes
          No

          Question three?
          - Yes
          No
        QUESTIONS_LIST
      end

      it 'does not create questions and renders the form with an error' do
        expect { post_create }.not_to change { QuizQuestion.count }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to have_flash_message(
          'Uploads may contain no more than 2 questions.',
          type: :alert,
        )
      end
    end

    context 'when the upload contains too many answers' do
      before { stub_const('QuizQuestions::CreateFromList::MAX_ANSWERS', 2) }

      let(:questions_list) do
        <<~QUESTIONS_LIST
          Which is biggest?
          The Earth
          - The Sun
          The Moon
        QUESTIONS_LIST
      end

      it 'does not create questions and renders the form with an error' do
        expect { post_create }.not_to change { QuizQuestion.count }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to have_flash_message(
          'Uploads may contain no more than 2 answers.',
          type: :alert,
        )
      end
    end
  end
end
