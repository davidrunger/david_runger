<template lang="pug">
Modal(:name='modalName' width='85%', maxWidth='400px')
  slot
    div #[b Minutes:] {{(timeInSeconds / 60).toFixed(1)}}
    div.my2
      h3.h3 Rep totals
      div(v-for='(count, exercise) in repTotals')
        span {{exercise}}:
        input(v-model.number='repTotals[exercise]')
    div
      el-checkbox(
        v-model='publiclyViewable'
      ) Publicly viewable
    div.flex.justify-around.mt2
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

<script lang='ts'>
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';
import { useModalStore } from '@/shared/modal/store';
import { useWorkoutsStore } from '@/workouts/store';
import { Workout } from './types';

export default {
  data() {
    return {
      modalName: 'confirm-workout',
      modalStore: useModalStore(),
      publiclyViewable: false,
      workoutsStore: useWorkoutsStore(),
    };
  },

  methods: {
    async saveWorkout() {
      try {
        const completedWorkout =
          await this.workoutsStore.createWorkout({ workout: {
            publiclyViewable: this.publiclyViewable,
            repTotals: this.repTotals,
            timeInSeconds: this.timeInSeconds,
          } }) as Workout;

        Toastify({
          text: 'Workout completion logged successfully!',
          position: 'center',
          duration: 2500,
        }).showToast();

        this.modalStore.hideModal({ modalName: this.modalName });
        this.workoutsStore.completeWorkout({ completedWorkout });
      } catch (error) {
        Toastify({
          text: 'Something went wrong',
          className: 'error',
          position: 'center',
          duration: 2500,
        }).showToast();
      }
    },
  },

  props: {
    repTotals: {
      type: Object,
      required: true,
    },
    timeInSeconds: {
      type: Number,
      required: true,
    },
  },
};
</script>
