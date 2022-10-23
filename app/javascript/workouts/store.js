import { defineStore } from 'pinia';
import { kyApi } from '@/shared/ky';
import { get } from 'lodash-es';

const state = () => {
  const workout =
    get(window, 'davidrunger.bootstrap.current_user.preferences.default_workout') ||
      {
        minutes: null,
        numberOfSets: null,
        exercises: [{}],
      };

  return {
    ...window.davidrunger.bootstrap,
    workout,
    workoutIsInProgress: false,
  };
};

const actions = {
  completeWorkout({ completedWorkout }) {
    this.workouts = this.workouts.concat(completedWorkout);
    this.workoutIsInProgress = false;
  },

  initializeWorkout() {
    this.workoutIsInProgress = true;
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
