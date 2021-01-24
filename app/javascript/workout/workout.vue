<template lang='pug'>
div(v-if='workout')
  WorkoutPlan(v-bind='workout')
NewWorkoutForm(v-else)
</template>

<script>
import { mapState } from 'vuex';

import NewWorkoutForm from 'workout/new_workout_form.vue';
import WorkoutPlan from 'workout/workout_plan.vue';

export default {
  components: {
    NewWorkoutForm,
    WorkoutPlan,
  },

  computed: mapState([
    'workout',
  ]),
};
</script>

<style>
th,
td {
  padding: 5px 10px;
}
</style>
