<template lang='pug'>
  div(v-if='workout')
    WorkoutPlan(v-bind='workout')
  NewWorkoutForm(
    v-else
    v-on:workout-initialized='onWorkoutInitialized'
  )
</template>

<script>
import NewWorkoutForm from 'workout/new_workout_form.vue';
import WorkoutPlan from 'workout/workout_plan.vue';

export default {
  components: {
    NewWorkoutForm,
    WorkoutPlan,
  },

  data() {
    return {
      workout: null,
    };
  },

  methods: {
    onWorkoutInitialized(workout) {
      this.workout = workout;
    },
  },
};
</script>
