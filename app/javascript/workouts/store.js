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

  createWorkout({ workout }) {
    return kyApi.post(
      Routes.api_workouts_path(),
      { json:
        { workout: {
          publicly_viewable: workout.publiclyViewable,
          rep_totals: workout.repTotals,
          time_in_seconds: workout.timeInSeconds,
        } } },
    ).json();
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

  updateWorkout({ workout, attributes }) {
    return kyApi.
      patch(
        Routes.api_workout_path(workout.id),
        { json: { workout: attributes } },
      ).
      json();
  },
};

export const useWorkoutsStore = defineStore('workouts', {
  state,
  actions,
});
