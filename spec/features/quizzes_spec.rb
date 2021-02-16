# frozen_string_literal: true

RSpec.describe 'Quizzes app' do
  let(:quiz_owner) { users(:admin) }
  let(:participant) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(quiz_owner) }

    it 'allows creating a new quiz, joining the quiz, answering questions, etc' do
      # visit new quiz page
      visit(new_quiz_path)

      # new quiz page expectations
      expect(page).to have_text('New Quiz')
      expect(page).to have_css('form')

      # submit new quiz form
      new_quiz_name = 'Birthday Quiz'
      fill_in('quiz_name', with: new_quiz_name)
      click_button('Create quiz')

      # quiz show page expectations
      expect(page).to have_css('h1', text: new_quiz_name)
      new_quiz = Quiz.order(:created_at).last!
      quiz_path = quiz_path(new_quiz)
      expect(page).to have_current_path(quiz_path)

      # quiz show page expectations without participant
      participant_name = 'Jessica'
      expect(page).not_to have_text(participant_name)

      # a participant joins
      Capybara.using_session('Quiz participant session') do
        sign_in(participant)
        visit(quiz_path)
        fill_in('display_name', with: participant_name)
        click_button('Join the quiz!')
      end

      # expect participant is now listed
      expect(page).to have_text(participant_name)

      # add questions
      click_link('Add questions')
      fill_in('questions', with: <<~QUESTIONS)
        Which is biggest?
        The earth
        -The sun
        The moon

        Which is currently farther from the sun?
        Neptune
        -Pluto
      QUESTIONS
      click_button('Save')

      # expect questions and answers are now listed on the show page
      expect(page).to have_text('Which is biggest?')
      expect(page).to have_text('The sun')
      expect(page).to have_text('Which is currently farther from the sun?')
      expect(page).to have_text('Neptune')

      # start the quiz
      click_button('Start quiz!')

      first_question, second_question = QuizQuestion.order(:created_at).last(2)

      # participant chooses a correct answer
      Capybara.using_session('Quiz participant session') do
        choose(first_question.answers.correct.first!.content)
        click_button('Submit')
      end

      # close question (reveal answer) and move to next question
      click_button('Close question')
      click_button('Next question')

      # participant chooses an incorrect answer
      Capybara.using_session('Quiz participant session') do
        choose(second_question.answers.first!.content)
        click_button('Submit')
      end

      # close question (reveal answer)
      click_button('Close question')

      # verify participant sees they got first question right and second question wrong
      Capybara.using_session('Quiz participant session') do
        expect(page).to have_text(/✓ ×/, wait: 5)
      end
    end
  end
end
