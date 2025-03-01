<template lang="pug">
section(v-if="workoutIsInProgress && typedWorkoutPlan")
  WorkoutPlan(v-bind="typedWorkoutPlan")
.px-8.py-2(v-else)
  NewWorkoutForm
  section.my-8
    h2.text-2xl Previous workouts
    WorkoutsTable(:isOwnWorkouts="true", :workouts="workouts")
  section.my-8
    h2.text-2xl Others' workouts
    WorkoutsTable(:workouts="others_workouts")
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { computed } from 'vue';

import type { WorkoutPlan as WorkoutPlanType } from '@/types';
import NewWorkoutForm from '@/workout/components/NewWorkoutForm.vue';
import WorkoutPlan from '@/workout/components/WorkoutPlan.vue';
import WorkoutsTable from '@/workout/components/WorkoutsTable.vue';
import { useWorkoutsStore } from '@/workout/store';

const workoutsStore = useWorkoutsStore();

const { others_workouts, workout, workoutIsInProgress, workouts } =
  storeToRefs(workoutsStore);

const typedWorkoutPlan = computed((): WorkoutPlanType | null => {
  if (workout.value.minutes && workout.value.numberOfSets) {
    return workout.value;
  } else {
    return null;
  }
});
</script>

<style>
th,
td {
  padding: 5px 10px;
}
</style>
