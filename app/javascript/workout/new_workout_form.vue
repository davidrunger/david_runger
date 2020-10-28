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
              v-model.number='numberOfSets'
              name='numberOfSets'
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
            | Reps per set
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
        :workouts='workouts'
      )
    div.my2
      h2.h2 Others' workouts
      WorkoutsTable(:workouts='others_workouts')
</template>

<script>
import { mapState } from 'vuex';

import WorkoutsTable from 'workout/workouts_table.vue';

export default {
  components: {
    WorkoutsTable,
  },

  computed: mapState([
    'others_workouts',
    'workouts',
  ]),

  data() {
    return {
      formstate: {},
      minutes: null,
      numberOfSets: null,
      exercises: [{}],
    };
  },

  methods: {
    initializeWorkout() {
      this.$store.commit(
        'setWorkout',
        {
          workout: {
            minutes: this.minutes,
            numberOfSets: this.numberOfSets,
            exercises: this.exercises,
          },
        },
      );
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
