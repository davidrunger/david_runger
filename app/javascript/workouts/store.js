import { defineStore } from 'pinia';
import { kyApi } from '@/shared/ky';

const state = () => ({
  ...window.davidrunger.bootstrap,
  workout: null,
});

const actions = {
  addCompletedWorkout({ completedWorkout }) {
    this.workouts = this.workouts.concat(completedWorkout);
  },

  initializeWorkout({ workout }) {
    kyApi.
      patch(
        Routes.api_user_path({ id: this.current_user.id }),
        { json: { user: { preferences: { default_workout: workout } } } },
      ).
      then(() => { this.setWorkout({ workout }); });
  },

  setWorkout({ workout }) {
    this.workout = workout;
  },
};

export const useWorkoutsStore = defineStore('workouts', {
  state,
  actions,
});
