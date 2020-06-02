<template lang='pug'>
  div.m2
    vue-form.mt3(:state='formstate')
      h2.h2 New Workout
      .my1
        label
          | Minutes
          validate
            el-input(
              v-model.number='minutes'
              name='minutes'
              required
              type='number'
            )
      .my1
        label
          | Sets
          validate
            el-input(
              v-model.number='sets'
              name='sets'
              required
              type='number'
            )
      .my1.clearfix(v-for='(exercise, index) in exercises')
        .col.col-6
          label
            | Exercise
            validate
              el-input(
                v-model='exercise.name'
                :name='`exercise-${index}-name`'
                required
                type='text'
              )
        .col.col-6
          label
            | Reps
            validate
              el-input(
                v-model.number='exercise.reps'
                :name='`exercise-${index}-reps`'
                required
                type='number'
              )
      .my1.center
        el-button(
          @click='exercises.push({})'
        ) Add exercise
      .mt3.center
        el-button(
          type='primary'
          :disabled='formstate.$invalid'
          @click='initializeWorkout()'
        ) Initialize Workout!
    div.my2
      h2.h2 Previous workouts
      WorkoutsTable(
        :isOwnWorkouts='true'
        :workouts='bootstrap.workouts'
      )
    div.my2
      PubliclySharedWorkouts
</template>

<script>
import PubliclySharedWorkouts from 'workout/publicly_shared_workouts.vue';
import WorkoutsTable from 'workout/workouts_table.vue';

export default {
  components: {
    PubliclySharedWorkouts,
    WorkoutsTable,
  },

  data() {
    return {
      formstate: {},
      minutes: null,
      sets: null,
      exercises: [{}],
    };
  },

  methods: {
    initializeWorkout() {
      this.$emit('workout-initialized', {
        minutes: this.minutes,
        sets: this.sets,
        exercises: this.exercises,
      });
    },
  },
};
</script>

<style>
th {
  font-weight: bold;
}

th,
td {
  text-align: center;
}

ol {
  list-style-type: decimal;
}
</style>
