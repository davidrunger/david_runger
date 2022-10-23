<template lang='pug'>
div.m2
  form.mt3
    h2.h2 New Workout
    .my1
      label
        | Minutes
        el-input(
          v-model.number='workoutsStore.workout.minutes'
          name='minutes'
          type='number'
          step='0.1'
        )
    .my1
      label
        | Sets
        el-input(
          v-model.number='workoutsStore.workout.numberOfSets'
          name='numberOfSets'
          type='number'
        )
    .my1.clearfix.flex(v-for='(exercise, index) in workout.exercises')
      .col.col-6
        label
          | Exercise
          el-input(
            v-model='exercise.name'
            :name='`exercise-${index}-name`'
            type='text'
          )
      .col.col-5
        label
          | Reps per set
          el-input(
            v-model.number='exercise.reps'
            :name='`exercise-${index}-reps`'
            type='number'
          )
      .col.col-1.flex.flex-column.items-center.justify-center
        button(type='button' @click='removeExercise(index)') X
    .my1.center
      el-button(
        @click='workout.exercises.push({})'
      ) Add exercise
    .mt3.center
      el-button(
        type='primary'
        @click='this.workoutsStore.initializeWorkout()'
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
import { mapState } from 'pinia';

import { useWorkoutsStore } from '@/workouts/store';
import WorkoutsTable from './workouts_table.vue';

export default {
  components: {
    WorkoutsTable,
  },

  computed: {
    ...mapState(useWorkoutsStore, [
      'others_workouts',
      'workout',
      'workouts',
    ]),
  },

  data() {
    return {
      workoutsStore: useWorkoutsStore(),
    };
  },

  methods: {
    removeExercise(index) {
      this.workout.exercises.splice(index, 1);
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
