<template lang="pug">
Modal(:name='modalName' width='85%', maxWidth='400px')
  slot
    h2.bold.mb2 Confirm workout
    div #[b Minutes:] {{(timeInSeconds / 60).toFixed(1)}}
    div #[b Rep totals:] {{JSON.stringify(repTotals)}}
    div.flex.justify-around.mt2
      el-button(
        @click="$store.commit('hideModal', { modalName })"
        type='text'
      ) Cancel
      el-button(
        type='primary'
        @click='saveWorkout'
      ) Save workout
</template>

<script>
import { get } from 'lodash';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';

export default {
  data() {
    return {
      modalName: 'confirm-workout',
    };
  },

  methods: {
    saveWorkout() {
      this.$http.post(this.$routes.api_workouts_path(), {
        workout: {
          time_in_seconds: this.timeInSeconds,
          rep_totals: this.repTotals,
        },
      }).then((response) => {
        if (response.status === 201) {
          Toastify({
            text: 'Workout completion logged successfully!',
            className: 'success',
            position: 'center',
            duration: 2500,
          }).showToast();

          this.$store.commit('hideModal', { modalName: this.modalName });
        }
      }).catch((error) => {
        const errorMessage = get(error, 'response.data.error', 'Something went wrong');
        Toastify({
          text: errorMessage,
          className: 'error',
          position: 'center',
          duration: 2500,
        }).showToast();
      });
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
