<template lang="pug">
form
  h2.text-2xl New Workout
  .my-2
    label
      | Minutes
      ElInput(
        v-model.number="workoutsStore.workout.minutes"
        name="minutes"
        type="number"
        step="0.1"
      )
  .my-2
    label
      | Sets
      ElInput(
        v-model.number="workoutsStore.workout.numberOfSets"
        name="numberOfSets"
        type="number"
      )
  .my-2.flex(v-for="(exercise, index) in workout.exercises")
    div(class="w-1/2")
      label
        | Exercise
        ElInput(
          v-model="exercise.name"
          :name="`exercise-${index}-name`"
          type="text"
        )
    div(class="w-5/12")
      label
        | Reps per set
        ElInput(
          v-model.number="exercise.reps"
          :name="`exercise-${index}-reps`"
          type="number"
        )
    .flex.flex-col.items-center.justify-end(class="w-1/12")
      ElButton(
        type="danger"
        @click="removeExercise(index)"
      ) X
  .my-2.text-center
    ElButton(@click="workout.exercises.push({})") Add exercise
  .mt-4.text-center
    ElButton(
      type="primary"
      @click="workoutsStore.initializeWorkout()"
    ) Initialize Workout!
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
