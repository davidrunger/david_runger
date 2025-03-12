RSpec.describe QuizzesController do
  before { sign_in(user) }

  let(:user) { users(:married_user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    it "lists the user's existing quizzes" do
      get_index

      user.quizzes.presence!.each do |quiz|
        expect(response.body).to have_link(quiz.name, href: quiz_path(quiz))
      end
    end

    it 'has a link to create a new quiz' do
      get_index
      expect(response.body).to have_link('Create new quiz', href: new_quiz_path)
    end
  end

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: quiz.hashid }) }

    let(:quiz) { Quiz.first! }

    context 'when viewed by the owner of the quiz' do
      before { expect(controller.current_user).to eq(quiz.owner) }

      it 'says "You are the quiz owner!"' do
        get_show
        expect(response.body).to have_text('You are the quiz owner!')
      end
    end

    context 'when viewed by a user who is not the quiz owner' do
      before { expect(controller.current_user).not_to eq(quiz.owner) }

      let(:user) { User.where.not(id: quiz.owner).first! }

      context 'when using plain, integer id rather than hashid URL param' do
        subject(:get_show) { get(:show, params: { id: quiz.id }) }

        it 'raises an error' do
          expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when the user is not yet a quiz participant' do
        before { quiz.participations.where(participant: user).find_each(&:destroy!) }

        it 'has a form to enter a display name and join the quiz' do
          get_show
          expect(response.body).to have_css('form input#display_name[type=text]')
        end
      end

      context 'when the user is a quiz participant' do
        let(:user) { quiz.participants.first! }

        context 'when the quiz is "active"' do
          before { quiz.update!(status: 'active') }

          context 'when the current question is "open"' do
            before do
              quiz.update!(current_question_number: 1)
              quiz.questions.order(:created_at).first!.update!(status: 'open')
            end

            it 'has a form to choose an answer' do
              get_show
              expect(response.body).to have_css(
                'form input[type="radio"][name="quiz_question_answer_selection[answer_id]"]',
              )
            end
          end

          context 'when the current question is "closed"' do
            before do
              quiz.update!(current_question_number: 1)
              quiz.questions.order(:created_at).first!.update!(status: QuizQuestion::CLOSED)
            end

            context 'when the question has been answered by at least one participant' do
              before do
                expect(QuizQuestionAnswerSelection.where(answer:, participation:)).to exist
              end

              let(:answer) { quiz.question_answers.first! }
              let(:participation) { quiz.participations.find_by!(participant: user) }

              it 'lists the participants who gave each answer' do
                get_show
                expect(response.body).
                  to have_text(/#{answer.content} \(.*#{participation.display_name}.*\)/)
              end
            end
          end
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

  describe '#update' do
    subject(:patch_update) do
      patch(
        :update,
        params: {
          id: quiz.hashid,
          quiz: {
            current_question_number: quiz.current_question_number + 1,
          },
        },
      )
    end

    let(:quiz) { Quiz.first! }

    it 'updates the quiz' do
      expect { patch_update }.to change { quiz.reload.current_question_number }.by(1)
    end
  end

  describe '#async_partial_delay_for_rails_env' do
    subject(:async_partial_delay_for_rails_env) do
      controller.send(:async_partial_delay_for_rails_env, delay_milliseconds)
    end

    let(:delay_milliseconds) { rand(1_000) }

    context 'when Rails.env is "test"', rails_env: :test do
      it 'returns 0' do
        expect(async_partial_delay_for_rails_env).to eq(0)
      end
    end

    context 'when Rails.env is "production"', rails_env: :production do
      it 'returns the provided delay milliseconds' do
        expect(async_partial_delay_for_rails_env).to eq(delay_milliseconds)
      end
    end

    context 'when Rails.env is "development"', rails_env: :development do
      it 'returns the provided delay milliseconds' do
        expect(async_partial_delay_for_rails_env).to eq(delay_milliseconds)
      end
    end
  end
end
