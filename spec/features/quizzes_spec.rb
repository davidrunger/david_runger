# frozen_string_literal: true

RSpec.describe 'Quizzes app' do
  let(:quiz_owner) { users(:admin) }
  let(:participant) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(quiz_owner) }

    it 'allows creating a new quiz and then shows that quiz' do
      visit(new_quiz_path)

      expect(page).to have_text('New Quiz')
      expect(page).to have_css('form')

      new_quiz_name = 'Birthday Quiz'
      fill_in('quiz_name', with: new_quiz_name)
      click_button('Create quiz')

      expect(page).to have_css('h1', text: new_quiz_name)
      new_quiz = Quiz.order(:created_at).last!
      quiz_path = quiz_path(new_quiz)
      expect(page).to have_current_path(quiz_path)

      participant_name = 'Jessica'
      expect(page).not_to have_text(participant_name)

      Capybara.using_session('Quiz participant session') do
        visit(quiz_path)
        sign_in(participant)
        visit(quiz_path)

        fill_in('display_name', with: participant_name)
        click_button('Join the quiz!')
      end

      expect(page).to have_text(participant_name)
    end
  end
end
