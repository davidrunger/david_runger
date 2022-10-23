import { defineStore } from 'pinia';
import { kyApi } from '@/shared/ky';
import { get } from 'lodash-es';

const state = () => ({
  ...window.davidrunger.bootstrap,
  workout:
    get(window, 'davidrunger.bootstrap.current_user.preferences.default_workout') ||
      {
        minutes: null,
        numberOfSets: null,
        exercises: [{}],
        active: false,
      },
});

const actions = {
  completeWorkout({ completedWorkout }) {
    this.workouts = this.workouts.concat(completedWorkout);
    this.workout.active = false;
  },

  initializeWorkout() {
    this.workout.active = true;
    kyApi.
      patch(
        Routes.api_user_path({ id: this.current_user.id }),
        { json: { user: { preferences: { default_workout: this.workout } } } },
      );
  },

  setWorkout({ workout }) {
    this.workout = workout;
  },
};

export const useWorkoutsStore = defineStore('workouts', {
  state,
  actions,
});
