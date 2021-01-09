# frozen_string_literal: true

RSpec.describe 'Quizzes app' do
  let(:user) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(user) }

    it 'allows creating a new quiz and then shows that quiz' do
      visit(new_quiz_path)

      expect(page).to have_text('New Quiz')
      expect(page).to have_css('form')

      new_quiz_name = 'Birthday Quiz'
      fill_in('quiz_name', with: new_quiz_name)
      click_button('Create quiz')

      expect(page).to have_css('h1', text: new_quiz_name)
    end
  end
end
