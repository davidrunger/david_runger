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
            answer_id: answer.id,
          },
        },
      )
    end

    before do
      quiz.update!(current_question_number: 1, status: 'active')
      question.update!(status: QuizQuestion::OPEN)
    end

    let(:answer) { question.answers.first! }
    let(:participation) { quiz.participations.find_by!(participant: user) }
    let(:question) { quiz.ordered_questions.first! }
    let(:quiz) { Quiz.first! }

    context 'when the user has not yet answered that question' do
      before { answer.selections.where(participation:).find_each(&:destroy!) }

      it 'creates a QuizQuestionAnswerSelection' do
        expect { post_create }.to change { QuizQuestionAnswerSelection.count }.by(1)
      end

      it 'stores the current question with the selected answer' do
        post_create

        selection = participation.quiz_question_answer_selections.find_by!(answer:)
        expect(selection.question).to eq(question)
      end
    end

    context 'when the user has already answered the question' do
      before { expect(answer.selections.where(participation:)).to exist }

      it 'responds with 422' do
        post_create

        expect(response).to have_http_status(422)
      end
    end

    context 'when the answer belongs to a different quiz' do
      let(:answer) do
        other_quiz = create(:quiz, owner: user)
        other_question = create(:quiz_question, quiz: other_quiz)
        create(:quiz_question_answer, question: other_question)
      end

      it 'does not create a selection and responds with 422' do
        expect { post_create }.not_to change { QuizQuestionAnswerSelection.count }
        expect(response).to have_http_status(422)
      end
    end

    context 'when the answer belongs to a future question' do
      let(:answer) { quiz.ordered_questions.second.answers.first! }

      it 'does not create a selection and responds with 422' do
        expect { post_create }.not_to change { QuizQuestionAnswerSelection.count }
        expect(response).to have_http_status(422)
      end
    end

    context 'when the current question is closed' do
      before { question.update!(status: QuizQuestion::CLOSED) }

      it 'does not create a selection and responds with 422' do
        expect { post_create }.not_to change { QuizQuestionAnswerSelection.count }
        expect(response).to have_http_status(422)
      end
    end

    context 'when the quiz has not started' do
      before { quiz.update!(status: 'unstarted') }

      it 'does not create a selection and responds with 422' do
        expect { post_create }.not_to change { QuizQuestionAnswerSelection.count }
        expect(response).to have_http_status(422)
      end
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

    before do
      quiz.update!(current_question_number: 1, status: 'active')
      question.update!(status: QuizQuestion::OPEN)
    end

    let(:answer_selection) { question.answer_selections.find_by!(participation:) }
    let(:new_answer) { question.answers.where.not(id: answer_selection.answer_id).first! }
    let(:participation) { quiz.participations.find_by!(participant: user) }
    let(:question) { quiz.ordered_questions.first! }
    let(:quiz) { Quiz.first! }

    it 'changes the `answer_id` of the QuizQuestionAnswerSelection' do
      expect { patch_update }.to change { answer_selection.reload.answer_id }.to(new_answer.id)
    end

    context 'when the new answer belongs to a different quiz' do
      let(:new_answer) do
        other_quiz = create(:quiz, owner: user)
        other_question = create(:quiz_question, quiz: other_quiz)
        create(:quiz_question_answer, question: other_question)
      end

      it 'does not update the selection and responds with 422' do
        expect { patch_update }.not_to change { answer_selection.reload.answer_id }
        expect(response).to have_http_status(422)
      end
    end

    context 'when the new answer belongs to a future question' do
      let(:new_answer) { quiz.ordered_questions.second.answers.first! }

      it 'does not update the selection and responds with 422' do
        expect { patch_update }.not_to change { answer_selection.reload.answer_id }
        expect(response).to have_http_status(422)
      end
    end

    context 'when the current question is closed' do
      before { question.update!(status: QuizQuestion::CLOSED) }

      it 'does not update the selection and responds with 422' do
        expect { patch_update }.not_to change { answer_selection.reload.answer_id }
        expect(response).to have_http_status(422)
      end
    end

    context 'when the selection belongs to an earlier question' do
      before { quiz.update!(current_question_number: 2) }

      let(:new_answer) { quiz.current_question.answers.first! }

      it 'does not replay the selection for the current question and responds with 422' do
        expect { patch_update }.not_to change { answer_selection.reload.answer_id }
        expect(response).to have_http_status(422)
      end
    end
  end
end
