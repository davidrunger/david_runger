<template lang='pug'>
div(v-if='workoutIsInProgress')
  WorkoutPlan(v-bind='workout')
.px3.py1(v-else)
  NewWorkoutForm
  div.my2
    h2.h2 Previous workouts
    WorkoutsTable(
      :isOwnWorkouts='true'
      :workouts='workouts'
    )
  div.my2
    h2.h2 Others' workouts
    WorkoutsTable(:workouts='others_workouts')
</template>

<script>
import { mapState } from 'pinia';
import { useWorkoutsStore } from '@/workouts/store';
import NewWorkoutForm from './new_workout_form.vue';
import WorkoutPlan from './workout_plan.vue';
import WorkoutsTable from './workouts_table.vue';

export default {
  components: {
    NewWorkoutForm,
    WorkoutPlan,
    WorkoutsTable,
  },

  computed: mapState(useWorkoutsStore, [
    'others_workouts',
    'workout',
    'workoutIsInProgress',
    'workouts',
  ]),
};
</script>

<style>
th,
td {
  padding: 5px 10px;
}
</style>
