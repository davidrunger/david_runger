<template lang='pug'>
div(v-if='workoutIsInProgress')
  WorkoutPlan(v-bind='typedWorkoutPlan')
.px-8.py-2(v-else)
  NewWorkoutForm
  div.my-8
    h2.text-2xl Previous workouts
    WorkoutsTable(
      :isOwnWorkouts='true'
      :workouts='workouts'
    )
  div.my-8
    h2.text-2xl Others' workouts
    WorkoutsTable(:workouts='others_workouts')
</template>

<script lang='ts'>
import { mapState } from 'pinia';
import { useWorkoutsStore } from '@/workouts/store';
import { WorkoutPlan as WorkoutPlanType } from '@/workouts/types';
import NewWorkoutForm from './new_workout_form.vue';
import WorkoutPlan from './workout_plan.vue';
import WorkoutsTable from './workouts_table.vue';

export default {
  components: {
    NewWorkoutForm,
    WorkoutPlan,
    WorkoutsTable,
  },

  computed: {
    ...mapState(useWorkoutsStore, [
      'others_workouts',
      'workout',
      'workoutIsInProgress',
      'workouts',
    ]),

    typedWorkoutPlan(): WorkoutPlanType {
      return this.workout as WorkoutPlanType;
    },
  },
};
</script>

<style>
th,
td {
  padding: 5px 10px;
}
</style>
