<template lang="pug">
Modal(:name='modalName' width='85%', maxWidth='400px')
  slot
    div #[b Minutes:] {{(timeInSeconds / 60).toFixed(1)}}
    .my-4
      h3 Rep totals
      div(v-for='(_count, exercise) in repTotals')
        span
          | {{exercise}}:
          |
        input(v-model.number='repTotals[exercise]')
    div
      el-checkbox(
        v-model='publiclyViewable'
      ) Publicly viewable
    .flex.justify-around.mt-4
      el-button(
        @click="modalStore.hideModal({ modalName })"
        type='primary'
        link
      ) Cancel
      el-button(
        type='primary'
        @click='saveWorkout'
      ) Save workout
</template>

<script setup lang="ts">
import Toastify from 'toastify-js';
import { ref } from 'vue';

import { useModalStore } from '@/shared/modal/store';
import { useWorkoutsStore } from '@/workout/store';
import type { Workout } from '@/workout/types';

const props = defineProps({
  repTotals: {
    type: Object,
    required: true,
  },
  timeInSeconds: {
    type: Number,
    required: true,
  },
});

const workoutsStore = useWorkoutsStore();
const modalStore = useModalStore();

const publiclyViewable = ref(false);

const modalName = 'confirm-workout';

async function saveWorkout() {
  try {
    const completedWorkout = (await workoutsStore.createWorkout({
      workout: {
        publiclyViewable: publiclyViewable.value,
        repTotals: props.repTotals,
        timeInSeconds: props.timeInSeconds,
      },
    })) as Workout;

    Toastify({
      text: 'Workout completion logged successfully!',
      position: 'center',
      duration: 2500,
    }).showToast();

    modalStore.hideModal({ modalName });
    workoutsStore.completeWorkout({ completedWorkout });
  } catch (error) {
    Toastify({
      text: 'Something went wrong',
      className: 'error',
      position: 'center',
      duration: 2500,
    }).showToast();
  }
}
</script>
