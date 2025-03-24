RSpec.describe 'Workout app' do
  let(:user) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(user) }

    context 'when the user has a default workout saved in their preferences' do
      before do
        user.default_workout ||= build(:json_preference, :default_workout, user:)
        user.default_workout.update!(json: {
          'minutes' => minutes,
          'exercises' => [
            { 'name' => exercise_1_name, 'reps' => exercise_1_reps },
            { 'name' => exercise_2_name, 'reps' => exercise_2_reps },
          ],
          'numberOfSets' => sets,
        })
      end

      let(:minutes) { 20 }
      let(:sets) { 10 }
      let(:exercise_1_name) { 'pushups' }
      let(:exercise_1_reps) { 15 }
      let(:exercise_2_name) { 'chinups' }
      let(:exercise_2_reps) { 5 }

      it 'renders the new-workout form preloaded with their default workout and shows past workouts of the user and public workouts of others' do
        visit workouts_path

        # Form for a new workout:
        expect(page).to have_text('New Workout')
        expect(page).to have_css('form')
        expect(page).to have_button('Initialize Workout!')

        expect(page).to have_field('minutes', with: minutes)
        expect(page).to have_field('numberOfSets', with: sets)
        expect(page).to have_field('exercise-0-name', with: exercise_1_name)
        expect(page).to have_field('exercise-0-reps', with: exercise_1_reps)
        expect(page).to have_field('exercise-1-name', with: exercise_2_name)
        expect(page).to have_field('exercise-1-reps', with: exercise_2_reps)

        expect(page).to have_button('Initialize Workout!')

        # Own past workouts:
        expect(page).to have_text('Previous workouts')
        expect(page).to have_text(
          user.workouts.first!.rep_totals.to_json.
            gsub(%r{\{|\}|"}, '').
            gsub(',', ', ').
            gsub(/:(?! )/, ': '),
        )

        # Public workouts of others:
        expect(page).to have_text("Others' workouts\nNone", normalize_ws: false)
        expect(page).not_to have_text('Loading')
      end

      context 'when the user initializes a workout and makes time and exercise count adjustments' do
        it 'adjusts the workout schedule/count table and default workout completion form values in accordance with the adjustments' do
          visit workouts_path

          click_on('Initialize Workout!')

          # Click to enable "Edit mode".
          find('span.el-switch__label', text: 'Edit mode').click

          # Check for some parts of the initial schedule.
          expect(page).to have_text(/\b2:13\b/)
          expect(page).to have_text(/\b4:26\b/)

          # Add +5 seconds to the second row.
          within(find_all('tbody tr')[1]) { find_all('td input')[0].fill_in(with: '5') }

          # Add an additional pushup to and subtract a chinup from the first row.
          within(find_all('tbody tr')[0]) { find_all('td input')[1].fill_in(with: '16') }
          within(find_all('tbody tr')[0]) { find_all('td input')[2].fill_in(with: '4') }

          # Check that time adjustment is reflected.
          expect(page).to have_text(/\b2:18\b/)
          expect(page).to have_text(/\b4:31\b/)

          # Check for exercise total count updates in the last row.
          expect(find_all('tbody tr')[10].find_all('td').map(&:text)).
            to eq(['', '', '', '', '151', '49'])

          # Add -10 seconds to the third row.
          within(find_all('tbody tr')[2]) { find_all('td input').first.fill_in(with: '-10') }

          # Check that time adjustments are reflected.
          expect(page).to have_text(/\b2:18\b/)
          expect(page).to have_text(/\b4:21\b/)

          # Check that exercise total count updates remain in place.
          expect(find_all('tbody tr')[10].find_all('td').map(&:text)).
            to eq(['', '', '', '', '151', '49'])

          # Click to disable "Edit mode".
          find('span.el-switch__label', text: 'Edit mode').click

          # Confirm that the adjustments are reflected in non-Edit mode, as well.
          expect(page).to have_text(/\b2:18\b/)
          expect(page).to have_text(/\b4:21\b/)

          # Check that exercise total count updates remain in place in non-Edit mode.
          expect(find_all('tbody tr')[10].find_all('td').map(&:text)).
            to eq(['', '', '151', '49'])

          # Start the workout.
          click_on('Start!')

          # Wait for the timer to start ticking.
          expect(page).not_to have_text('Time Elapsed: 0:00')

          # End the workout.
          click_on('Mark workout as complete!')

          # Check that prefilled inputs reflect the count adjustments.
          within('.modal-container') do
            expect(page).to have_field('pushups:', with: '16')
            expect(page).to have_field('chinups:', with: '4')
          end

          # Save the workout.
          click_on('Save workout')

          # Check that the workout is logged successfully.
          expect(page).to have_toastify_toast('Workout completion logged successfully!')
          within_section('Previous workouts') do
            expect(page).to have_text('chinups: 4, pushups: 16')
          end
        end
      end
    end
  end
end
