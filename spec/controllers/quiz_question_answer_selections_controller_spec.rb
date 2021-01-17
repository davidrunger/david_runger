# frozen_string_literal: true

RSpec.describe QuizQuestionAnswerSelectionsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) do
      post(
        :create,
        params: {
          quiz_id: quiz.hashid,
          quiz_question_answer_selection: {
            answer_id: quiz.question_answers.first!.id,
          },
        },
      )
    end

    let(:quiz) { Quiz.first! }

    it 'creates a QuizQuestionAnswerSelection' do
      expect { post_create }.to change { QuizQuestionAnswerSelection.count }.by(1)
    end
  end

  describe '#update' do
    subject(:patch_update) do
      post(
        :update,
        params: {
          id: answer_selection.id,
          quiz_id: quiz.hashid,
          quiz_question_answer_selection: {
            answer_id: new_answer.id,
          },
        },
      )
    end

    let(:answer_selection) do
      QuizQuestionAnswerSelection.where(participation_id: user.quiz_participations).first!
    end
    let(:quiz) { answer_selection.quiz }
    let(:new_answer) do
      answer_selection.quiz.question_answers.where.not(id: answer_selection.answer_id).first!
    end

    it 'changes the `answer_id` of the QuizQuestionAnswerSelection' do
      expect { patch_update }.to change { answer_selection.reload.answer_id }.to(new_answer.id)
    end
  end
end
