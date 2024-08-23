import { defineStore } from 'pinia';

import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import * as RoutesType from '@/rails_assets/routes';
import { http } from '@/shared/http';
import { kyApi } from '@/shared/ky';
import type { Workout, WorkoutPlan } from '@/types';

import { Bootstrap, NewWorkoutAttributes } from './types';

declare const Routes: typeof RoutesType;

const bootstrap = untypedBootstrap as Bootstrap;

export const useWorkoutsStore = defineStore('workouts', {
  state: () => {
    const workout = bootstrap.current_user.default_workout || {
      minutes: null as null | number,
      numberOfSets: null as null | number,
      exercises: [{}],
    };

    return {
      ...(window.davidrunger.bootstrap as Bootstrap),
      workout,
      workoutIsInProgress: false,
    };
  },

  actions: {
    completeWorkout({ completedWorkout }: { completedWorkout: Workout }) {
      this.workouts = this.workouts.concat(completedWorkout);
      this.workoutIsInProgress = false;
    },

    createWorkout({ workout }: { workout: NewWorkoutAttributes }) {
      return kyApi
        .post(Routes.api_workouts_path(), {
          json: {
            workout: {
              publicly_viewable: workout.publiclyViewable,
              rep_totals: workout.repTotals,
              time_in_seconds: workout.timeInSeconds,
            },
          },
        })
        .json();
    },

    initializeWorkout() {
      this.workoutIsInProgress = true;
      http.patch(Routes.api_json_preferences_path(), {
        preference_type: 'default_workout',
        json: this.workout,
      });
    },

    setWorkout({ workout }: { workout: WorkoutPlan }) {
      this.workout = workout;
    },

    updateWorkout({
      workout,
      attributes,
    }: {
      workout: Workout;
      attributes: Workout;
    }) {
      return kyApi
        .patch(Routes.api_workout_path(workout.id), {
          json: { workout: attributes },
        })
        .json();
    },
  },
});
