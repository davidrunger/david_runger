<template lang='pug'>
div.m2
  form.mt3
    h2.h2 New Workout
    .my1
      label
        | Minutes
        el-input(
          v-model.number='minutes'
          name='minutes'
          type='number'
        )
    .my1
      label
        | Sets
        el-input(
          v-model.number='numberOfSets'
          name='numberOfSets'
          type='number'
        )
    .my1.clearfix(v-for='(exercise, index) in exercises')
      .col.col-6
        label
          | Exercise
          el-input(
            v-model='exercise.name'
            :name='`exercise-${index}-name`'
            type='text'
          )
      .col.col-6
        label
          | Reps per set
          el-input(
            v-model.number='exercise.reps'
            :name='`exercise-${index}-reps`'
            type='number'
          )
    .my1.center
      el-button(
        @click='exercises.push({})'
      ) Add exercise
    .mt3.center
      el-button(
        type='primary'
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

import WorkoutsTable from './workouts_table.vue';

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
