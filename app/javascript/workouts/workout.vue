<template lang='pug'>
div(v-if='workoutIsInProgress')
  WorkoutPlan(v-bind='workout')
NewWorkoutForm(v-else)
</template>

<script>
import { mapState } from 'pinia';
import { useWorkoutsStore } from '@/workouts/store';
import NewWorkoutForm from './new_workout_form.vue';
import WorkoutPlan from './workout_plan.vue';

export default {
  components: {
    NewWorkoutForm,
    WorkoutPlan,
  },

  computed: mapState(useWorkoutsStore, [
    'workout',
    'workoutIsInProgress',
  ]),
};
</script>

<style>
th,
td {
  padding: 5px 10px;
}
</style>
