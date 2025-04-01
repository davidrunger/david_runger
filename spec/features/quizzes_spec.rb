RSpec.describe 'Quizzes app' do
  let(:quiz_owner) { users(:married_user) }
  let(:existing_quiz) { quiz_owner.quizzes.first! }
  let(:participant) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(quiz_owner) }

    let(:participant_name) { 'Jessica' }

    it 'allows creating a new quiz, joining the quiz, answering questions, etc', wait_time: 10 do
      # visit new quiz page
      visit(new_quiz_path)

      # new quiz page expectations
      expect(page).to have_text('New Quiz')
      expect(page).to have_css('form')

      # submit new quiz form
      new_quiz_name = 'Birthday Quiz'
      fill_in('quiz_name', with: new_quiz_name)
      button_click_time = Time.current
      click_on('Create quiz')

      # quiz show page expectations
      expect(page).to have_css('h1', text: new_quiz_name)
      new_quizzes = Quiz.where('quizzes.created_at > ?', button_click_time)
      expect(new_quizzes.size).to eq(1)
      new_quiz = new_quizzes.first
      quiz_path = quiz_path(new_quiz)
      expect(page).to have_current_path(quiz_path)

      # quiz show page expectations without participant
      expect(page).not_to have_text(participant_name)

      # A participant joins.
      using_session('Quiz participant session') do
        wait.for do
          sign_in(participant)
          visit(quiz_path)
          Capybara.using_wait_time(0.1) do # Override `wait_time: 10` set for the spec overall.
            page.has_css?('input#display_name')
          end
        end.to eq(true)

        fill_in('display_name', with: participant_name)
        click_on('Join the quiz!')
      end

      # expect participant is now listed
      expect(page).to have_text(participant_name)

      # add questions
      click_on('Add questions')
      expect(page).to have_css('textarea#questions')
      fill_in('questions', with: <<~QUESTIONS)
        Which is biggest?
        The earth
        -The sun
        The moon

        Which is currently farther from the sun?
        Neptune
        -Pluto
      QUESTIONS
      click_on('Save')

      # expect questions and answers are now listed on the show page
      expect(page).to have_text('Which is biggest?')
      expect(page).to have_text('The sun')
      expect(page).to have_text('Which is currently farther from the sun?')
      expect(page).to have_text('Neptune')

      # start the quiz
      click_on('Start quiz!')
      expect(page).to have_text('Question 1')

      first_question, second_question = QuizQuestion.order(:created_at).last(2)

      # participant chooses a correct answer
      using_session('Quiz participant session') do
        choose(first_question.answers.correct.first!.content)
        click_on('Submit')
        expect(page).to have_css('.font-bold', text: participant_name)
        expect(page).to have_css('ol li:nth-of-type(1)', text: /\A\z/)
      end

      # refresh the page and check that the respondent's name is still bolded
      visit(page.current_url)
      expect(page).to have_css('.font-bold', text: participant_name)

      # close question (reveal answer) and move to next question
      click_on('Close question')
      expect(page).to have_css('.text-lime-600', text: "(#{participant_name})")
      expect(page).to have_text("#{participant_name} (1/2)")

      click_on('Next question')
      expect(page).to have_text('Question 2')
      expect(page).to have_text("#{participant_name} (1/2)")

      # participant chooses an incorrect answer
      using_session('Quiz participant session') do
        choose(second_question.answers.incorrect.first!.content)
        click_on('Submit')
        expect(page).to have_css('.font-bold', text: participant_name)
        expect(page).to have_css('ol li:nth-of-type(1)', text: /\A✓\z/)
      end

      # close question (reveal answer)
      click_on('Close question')
      expect(page).to have_css('.text-red-600', text: "(#{participant_name})")
      expect(page).to have_text("#{participant_name} (1/2)")

      # verify participant sees they got first question right and second question wrong
      using_session('Quiz participant session') do
        expect(page).to have_text(/✓ ×/, wait: 5)
      end

      click_on('Close quiz')

      expect(page).to have_text("#{new_quiz_name} Final results #{participant_name} (1/2)")
    end

    it 'allows destroying a quiz' do
      visit quizzes_path

      quiz_to_destroy = existing_quiz

      expect {
        accept_confirm { click_on('Delete') }

        expect(page).to have_flash_message("Destroyed quiz '#{quiz_to_destroy.name}'.")
      }.to change {
        Quiz.find_by(id: quiz_to_destroy.id)
      }.from(Quiz).to(nil)
    end
  end
end
