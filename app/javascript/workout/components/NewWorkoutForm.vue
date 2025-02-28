<template lang="pug">
form
  h2.text-2xl New Workout
  .my-2
    label
      | Minutes
      el-input(
        v-model.number='workoutsStore.workout.minutes',
        name='minutes',
        type='number',
        step='0.1'
      )
  .my-2
    label
      | Sets
      el-input(
        v-model.number='workoutsStore.workout.numberOfSets',
        name='numberOfSets',
        type='number'
      )
  .my-2.clearfix.flex(v-for='(exercise, index) in workout.exercises')
    .col.col-6
      label
        | Exercise
        el-input(
          v-model='exercise.name',
          :name='`exercise-${index}-name`',
          type='text'
        )
    .col.col-5
      label
        | Reps per set
        el-input(
          v-model.number='exercise.reps',
          :name='`exercise-${index}-reps`',
          type='number'
        )
    .col.col-1.flex.flex-col.items-center.justify-end
      el-button(type='danger', @click='removeExercise(index)') X
  .my-2.text-center
    el-button(@click='workout.exercises.push({})') Add exercise
  .mt-4.text-center
    el-button(type='primary', @click='workoutsStore.initializeWorkout()') Initialize Workout!
</template>

<script setup lang="ts">
import { ElButton, ElInput } from 'element-plus';
import { storeToRefs } from 'pinia';

import { useWorkoutsStore } from '@/workout/store';

const workoutsStore = useWorkoutsStore();

const { workout } = storeToRefs(workoutsStore);

function removeExercise(index: number) {
  workout.value.exercises.splice(index, 1);
}
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
