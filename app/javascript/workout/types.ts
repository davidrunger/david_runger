import type {
  RepTotals,
  UserSerializerWithDefaultWorkout,
  Workout,
} from '@/types';

export type NewWorkoutAttributes = {
  publiclyViewable: boolean;
  repTotals: RepTotals;
  timeInSeconds: number;
};

export type Bootstrap = {
  current_user: UserSerializerWithDefaultWorkout;
  others_workouts: Array<Workout>;
  workouts: Array<Workout>;
};
