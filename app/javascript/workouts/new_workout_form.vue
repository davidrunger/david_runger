<template lang='pug'>
form
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
  .mt2.center
    el-button(
      type='primary'
      @click='this.workoutsStore.initializeWorkout()'
    ) Initialize Workout!
</template>

<script>
import { mapState } from 'pinia';

import { useWorkoutsStore } from '@/workouts/store';

export default {
  computed: {
    ...mapState(useWorkoutsStore, [
      'workout',
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
