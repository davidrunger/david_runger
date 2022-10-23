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
      expect(page).to have_button('Initialize Workout!')

      # own workouts
      expect(page).to have_text('Previous workouts')
      expect(page).to have_text(
        user.workouts.first!.rep_totals.to_json.
          gsub(%r{\{|\}|"}, '').
          gsub(',', ', ').
          gsub(/:(?! )/, ': '),
      )

      # public workouts of others
      expect(page).to have_text("Others' workouts\nNone", normalize_ws: false)
      expect(page).not_to have_text('Loading')
    end

    context 'when the user has a default workout saved in their preferences' do
      before do
        user.update(
          preferences: {
            'default_workout' => {
              'minutes' => minutes,
              'exercises' => [
                { 'name' => exercise_1_name, 'reps' => exercise_1_reps },
                { 'name' => exercise_2_name, 'reps' => exercise_2_reps },
              ],
              'numberOfSets' => sets,
            },
          },
        )
      end

      let(:minutes) { 20 }
      let(:sets) { 10 }
      let(:exercise_1_name) { 'pushups' }
      let(:exercise_1_reps) { 15 }
      let(:exercise_2_name) { 'chinups' }
      let(:exercise_2_reps) { 5 }

      it 'renders the new-workout form preloaded with their default workout' do
        visit workout_path

        expect(page).to have_text('New Workout')
        expect(page).to have_css('form')

        expect(page).to have_field('minutes', with: minutes)
        expect(page).to have_field('numberOfSets', with: sets)
        expect(page).to have_field('exercise-0-name', with: exercise_1_name)
        expect(page).to have_field('exercise-0-reps', with: exercise_1_reps)
        expect(page).to have_field('exercise-1-name', with: exercise_2_name)
        expect(page).to have_field('exercise-1-reps', with: exercise_2_reps)

        expect(page).to have_button('Initialize Workout!')
      end
    end
  end
end
