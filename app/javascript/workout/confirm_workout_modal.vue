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
      publiclyViewable: false,
    };
  },

  methods: {
    saveWorkout() {
      this.$http.post(this.$routes.api_workouts_path(), {
        workout: {
          publicly_viewable: this.publiclyViewable,
          rep_totals: this.repTotals,
          time_in_seconds: this.timeInSeconds,
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

          const completedWorkout = response.data;
          this.$store.commit('addCompletedWorkout', { completedWorkout });
          this.$store.commit('setWorkout', { workout: null });
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
