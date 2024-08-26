import type {
  Intersection,
  RepTotals,
  UserSerializerWithDefaultWorkout,
  Workout,
} from '@/types';
import { WorkoutsIndexBootstrap } from '@/types/bootstrap/WorkoutsIndexBootstrap';

export type NewWorkoutAttributes = {
  publiclyViewable: boolean;
  repTotals: RepTotals;
  timeInSeconds: number;
};

export type Bootstrap = Intersection<
  {
    current_user: UserSerializerWithDefaultWorkout;
    others_workouts: Array<Workout>;
    workouts: Array<Workout>;
  },
  WorkoutsIndexBootstrap
>;
