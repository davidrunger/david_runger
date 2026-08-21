RSpec.describe QuizQuestionAnswerSelection do
  context 'when a participant has not yet answered a question' do
    before { question.answer_selections.where(participation:).find_each(&:destroy!) }

    let(:participation) { QuizParticipation.first! }
    let(:question) { participation.quiz.questions.first! }

    context 'when attempting to create a new answer selection for that question' do
      let(:new_selection) do
        build(:quiz_question_answer_selection, participation:, answer: question.answers.first!)
      end

      it 'considers the new selection to be valid' do
        expect(new_selection).to be_valid
      end
    end
  end

  context 'when a participant has already answered a question' do
    let(:participation) { existing_answer_selection.participation }
    let(:existing_answer_selection) { QuizQuestionAnswerSelection.first! }
    let(:question) { existing_answer_selection.question }

    it 'the record is considered to be valid' do
      expect(existing_answer_selection).to be_valid
    end

    context 'when attempting to create a new answer selection for the same question' do
      let(:new_selection) do
        build(:quiz_question_answer_selection, participation:, answer: different_answer)
      end
      let(:different_answer) do
        question.answers.where.not(id: existing_answer_selection.answer_id).first!
      end

      it 'considers the new selection not to be valid' do
        expect(new_selection).not_to be_valid
      end

      it 'is rejected by the database uniqueness constraint without model validation' do
        expect { new_selection.save!(validate: false) }.
          to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  context 'when the answer belongs to a different quiz than the participation' do
    let(:answer) { create(:quiz_question_answer, question:) }
    let(:other_quiz) { create(:quiz, owner: participation.participant) }
    let(:participation) { QuizParticipation.first! }
    let(:question) { create(:quiz_question, quiz: other_quiz) }
    let(:selection) { build(:quiz_question_answer_selection, answer:, participation:) }

    it 'considers the selection invalid' do
      expect(selection).not_to be_valid
      expect(selection.errors[:answer]).to include("must belong to the participation's quiz")
    end
  end

  context 'when the answer and selected question do not match' do
    let(:answer) { participation.quiz.questions.first!.answers.first! }
    let(:participation) { QuizParticipation.first! }
    let(:question) { participation.quiz.questions.where.not(id: answer.question_id).first! }
    let(:selection) do
      build(:quiz_question_answer_selection, answer:, participation:, question:)
    end

    it 'considers the selection invalid' do
      expect(selection).not_to be_valid
      expect(selection.errors[:answer]).to include('must belong to the selected question')
    end
  end

  context 'when the answer is missing' do
    let(:participation) { QuizParticipation.first! }
    let(:question) { participation.quiz.questions.first! }
    let(:selection) do
      build(:quiz_question_answer_selection, answer: nil, participation:, question:)
    end

    it 'does not add a question-mismatch error' do
      expect(selection).not_to be_valid
      expect(selection.errors[:answer]).not_to include('must belong to the selected question')
    end
  end

  context 'when the participation is missing' do
    let(:question) { QuizQuestion.first! }
    let(:answer) { question.answers.first! }
    let(:selection) do
      build(:quiz_question_answer_selection, answer:, participation: nil, question:)
    end

    it 'does not add a quiz-mismatch error' do
      expect(selection).not_to be_valid
      expect(selection.errors[:answer]).not_to include("must belong to the participation's quiz")
    end
  end
end
