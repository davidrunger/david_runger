import { defineStore } from 'pinia';

import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { http } from '@/lib/http';
import {
  api_json_preferences_path,
  api_workout_path,
  api_workouts_path,
} from '@/rails_assets/routes';
import type { Intersection, Workout, WorkoutPlan } from '@/types';
import { WorkoutUpdateResponse } from '@/types/responses/WorkoutUpdateResponse';

import { Bootstrap, NewWorkoutAttributes } from './types';

const bootstrap = untypedBootstrap as Bootstrap;

export const useWorkoutsStore = defineStore('workouts', {
  state: () => {
    const workout = bootstrap.current_user.default_workout || {
      minutes: null as null | number,
      numberOfSets: null as null | number,
      exercises: [{}],
    };

    return {
      ...bootstrap,
      workout,
      workoutIsInProgress: false,
    };
  },

  actions: {
    completeWorkout({ completedWorkout }: { completedWorkout: Workout }) {
      this.workouts = this.workouts.concat(completedWorkout);
      this.workoutIsInProgress = false;
    },

    async createWorkout({ workout }: { workout: NewWorkoutAttributes }) {
      return await http.post<Workout>(api_workouts_path(), {
        workout: {
          publicly_viewable: workout.publiclyViewable,
          rep_totals: workout.repTotals,
          time_in_seconds: workout.timeInSeconds,
        },
      });
    },

    initializeWorkout() {
      this.workoutIsInProgress = true;
      http.patch(api_json_preferences_path(), {
        preference_type: 'default_workout',
        json: this.workout,
      });
    },

    setWorkout({ workout }: { workout: WorkoutPlan }) {
      this.workout = workout;
    },

    async updateWorkout({
      workout,
      attributes,
    }: {
      workout: Workout;
      attributes: Workout;
    }) {
      return await http.patch<Intersection<Workout, WorkoutUpdateResponse>>(
        api_workout_path(workout.id),
        {
          workout: attributes,
        },
      );
    },
  },
});
