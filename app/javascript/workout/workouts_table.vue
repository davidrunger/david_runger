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
      td {{workout.created_at | prettyTime}}
      td(v-if='!isOwnWorkouts') {{workout.username}}
      td {{(workout.time_in_seconds / 60).toFixed(1)}}
      td {{workout.rep_totals | prettyObject}}
      td(v-if='isOwnWorkouts')
        el-checkbox(
          v-model='workout.publicly_viewable'
          @change='savePubliclyViewableChange(workout.id, workout.publicly_viewable)'
        )
div(v-else) None
</template>

<script>
import { sortBy } from 'lodash';
import strftime from 'strftime';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';

export default {
  computed: {
    workoutsSortedByCreatedAtDesc() {
      return sortBy(this.workouts, 'created_at').reverse();
    },
  },

  filters: {
    prettyObject(object) {
      return JSON.stringify(object).
        replace(/{|}|"/g, '').
        replace(/,/g, ', ').
        replace(/:(?! )/g, ': ');
    },

    prettyTime(timeString) {
      return strftime('%b %-d, %Y at %-l:%M%P', new Date(timeString));
    },
  },

  methods: {
    savePubliclyViewableChange(workoutId, newPubliclyViewableValue) {
      const payload = { workout: { publicly_viewable: newPubliclyViewableValue } };

      this.$http.
        patch(Routes.api_workout_path(workoutId), payload).
        then((response) => {
          if (response.status === 200) {
            const message = response.data.publicly_viewable ?
              'Workout is now publicly viewable.' :
              'Workout is now private.';
            Toastify({
              text: message,
              className: 'success',
              position: 'center',
              duration: 1800,
            }).showToast();
          }
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
