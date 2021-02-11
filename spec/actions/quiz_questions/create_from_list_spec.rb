# frozen_string_literal: true

RSpec.describe QuizQuestions::CreateFromList do
  subject(:action) { QuizQuestions::CreateFromList.new(action_inputs) }

  before { quiz.questions.find_each(&:destroy!) }

  let(:action_inputs) do
    {
      quiz: quiz,
      questions_list: questions_list,
    }
  end
  let(:quiz) { create(:quiz, owner: users(:admin)) }
  let(:questions_list) do
    <<~QUESTIONS_LIST
      What's your Hogwarts house?
      Gryffindor
      Hufflepuff
      -Ravenclaw
      Slytherin

      Do you think that smarter people are usually capable of deeper love?
      Yes
      - No
    QUESTIONS_LIST
  end

  describe '#run!' do
    subject(:run!) { action.run! }

    it 'creates two questions and six answers' do
      expect {
        run!
      }.to change {
        quiz.questions.count
      }.by(2).and change {
        quiz.question_answers.count
      }.by(6)
    end

    describe 'the created questions and answers' do
      before { run! }

      describe 'the first question created' do
        let(:first_question) { quiz.questions.order(:created_at).last(2).first }

        it 'creates the question and its answers correctly' do
          expect(first_question.content).to eq("What's your Hogwarts house?")
        end

        it 'creates the question answers correctly' do
          expect(first_question.answers.order(:created_at).pluck(:content, :is_correct)).to eq(
            [
              ['Gryffindor', false],
              ['Hufflepuff', false],
              ['Ravenclaw', true],
              ['Slytherin', false],
            ],
          )
        end
      end

      describe 'the second question created' do
        let(:second_question) { quiz.questions.order(:created_at).last! }

        it 'creates the question and its answers correctly' do
          expect(second_question.content).
            to eq('Do you think that smarter people are usually capable of deeper love?')
        end

        it 'creates the question answers correctly' do
          expect(second_question.answers.order(:created_at).pluck(:content, :is_correct)).to eq(
            [
              ['Yes', false],
              ['No', true],
            ],
          )
        end
      end
    end
  end
end
