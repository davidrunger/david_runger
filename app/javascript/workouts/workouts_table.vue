<template lang='pug'>
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
      td {{prettyTime(workout.created_at)}}
      td(v-if='!isOwnWorkouts') {{workout.username}}
      td {{(workout.time_in_seconds / 60).toFixed(1)}}
      td {{prettyObject(workout.rep_totals)}}
      td(v-if='isOwnWorkouts')
        el-checkbox(
          v-model='workout.publicly_viewable'
          @change='savePubliclyViewableChange(workout)'
        )
div(v-else) None
</template>

<script>
import { useWorkoutsStore } from '@/workouts/store';
import { sortBy } from 'lodash-es';
import strftime from 'strftime';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';

export default {
  computed: {
    workoutsSortedByCreatedAtDesc() {
      return sortBy(this.workouts, 'created_at').reverse();
    },
  },

  data() {
    return {
      workoutsStore: useWorkoutsStore(),
    };
  },

  methods: {
    prettyObject(object) {
      return JSON.stringify(object).
        replace(/{|}|"/g, '').
        replace(/,/g, ', ').
        replace(/:(?! )/g, ': ');
    },

    prettyTime(timeString) {
      return strftime('%b %-d, %Y at %-l:%M%P', new Date(timeString));
    },

    savePubliclyViewableChange(workout) {
      this.workoutsStore.updateWorkout({ workout, attributes: workout }).
        then(responseData => {
          const message = responseData.publicly_viewable ?
            'Workout is now publicly viewable.' :
            'Workout is now private.';
          Toastify({
            text: message,
            className: 'success',
            position: 'center',
            duration: 1800,
          }).showToast();
        });
    },
  },

  props: {
    isOwnWorkouts: {
      type: Boolean,
      default: false,
    },
    workouts: {
      type: Array,
      required: true,
    },
  },
};
</script>
