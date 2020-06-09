# frozen_string_literal: true

RSpec.describe 'Workout app' do
  let(:user) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(user) }

    it 'renders expected content' do
      visit workout_path

      # form for new workout
      expect(page).to have_text('New Workout')
      expect(page).to have_css('form')
      expect(page).to have_button('Initialize Workout!', disabled: true)

      # own workouts
      expect(page).to have_text('Previous workouts')
      expect(page).to have_text(
        user.workouts.first!.rep_totals.to_json.
          gsub(%r{\{|\}|"}, '').
          gsub(',', ', ').
          gsub(/:(?! )/, ': '),
      )

      # public workouts of others
      expect(page).to have_text("Others' workouts\nNone")
      expect(page).not_to have_text('Loading')
    end
  end
end
