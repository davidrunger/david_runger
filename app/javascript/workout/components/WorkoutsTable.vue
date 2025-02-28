<template lang="pug">
table(v-if='workouts.length')
  thead
    tr
      th Completed
      th(v-if='!isOwnWorkouts') User
      th Time (minutes)
      th Rep totals
      th(v-if='isOwnWorkouts') Public
  tbody
    tr(v-for='workout in workoutsSortedByCreatedAtDesc')
      td {{ prettyTime(workout.created_at) }}
      td(v-if='!isOwnWorkouts') {{ workout.username }}
      td {{ (workout.time_in_seconds / 60).toFixed(1) }}
      td {{ prettyObject(workout.rep_totals) }}
      td(v-if='isOwnWorkouts')
        el-checkbox(
          v-model='workout.publicly_viewable',
          @change='savePubliclyViewableChange(workout)'
        )
div(v-else) None
</template>

<script setup lang="ts">
import { ElCheckbox } from 'element-plus';
import { sortBy } from 'lodash-es';
import strftime from 'strftime';
import { computed, type PropType } from 'vue';

import { toast } from '@/lib/toasts';
import type { Workout } from '@/types';
import { useWorkoutsStore } from '@/workout/store';

const props = defineProps({
  isOwnWorkouts: {
    type: Boolean,
    default: false,
  },
  workouts: {
    type: Array as PropType<Array<Workout>>,
    required: true,
  },
});

const workoutsStore = useWorkoutsStore();

const workoutsSortedByCreatedAtDesc = computed((): Array<Workout> => {
  return sortBy(props.workouts, 'created_at').reverse();
});

function prettyObject(object: object) {
  return JSON.stringify(object)
    .replace(/{|}|"/g, '')
    .replace(/,/g, ', ')
    .replace(/:(?! )/g, ': ');
}

function prettyTime(timeString: string) {
  return strftime('%b %-d, %Y at %-l:%M%P', new Date(timeString));
}

async function savePubliclyViewableChange(workout: Workout) {
  const responseData = await workoutsStore.updateWorkout({
    workout,
    attributes: workout,
  });

  const message =
    responseData.publicly_viewable ?
      'Workout is now publicly viewable.'
    : 'Workout is now private.';

  toast(message);
}
</script>
