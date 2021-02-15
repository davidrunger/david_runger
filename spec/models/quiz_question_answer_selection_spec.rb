# frozen_string_literal: true

RSpec.describe QuizQuestionAnswerSelection do
  context 'when a participant has not yet answered a question' do
    before { question.answer_selections.where(participation: participation).find_each(&:destroy!) }

    let(:participation) { QuizParticipation.first! }
    let(:question) { participation.quiz.questions.first! }

    context 'when attempting to create a new answer selection for that question' do
      let(:new_selection) do
        build(
          :quiz_question_answer_selection,
          participation: participation,
          answer: question.answers.first!,
        )
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
        build(
          :quiz_question_answer_selection,
          participation: participation,
          answer: different_answer,
        )
      end
      let(:different_answer) do
        question.answers.where.not(id: existing_answer_selection.answer_id).first!
      end

      it 'considers the new selection not to be valid' do
        expect(new_selection).not_to be_valid
      end
    end
  end
end
