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

<script lang="ts">
import { sortBy } from 'lodash-es';
import strftime from 'strftime';
import Toastify from 'toastify-js';
import { defineComponent, PropType } from 'vue';

import { useWorkoutsStore } from '@/workouts/store';

import { Workout } from './types';

export default defineComponent({
  props: {
    isOwnWorkouts: {
      type: Boolean,
      default: false,
    },
    workouts: {
      type: Array as PropType<Array<Workout>>,
      required: true,
    },
  },

  data() {
    return {
      workoutsStore: useWorkoutsStore(),
    };
  },

  computed: {
    workoutsSortedByCreatedAtDesc(): Array<Workout> {
      return sortBy(this.workouts, 'created_at').reverse();
    },
  },

  methods: {
    prettyObject(object: object) {
      return JSON.stringify(object)
        .replace(/{|}|"/g, '')
        .replace(/,/g, ', ')
        .replace(/:(?! )/g, ': ');
    },

    prettyTime(timeString: string) {
      return strftime('%b %-d, %Y at %-l:%M%P', new Date(timeString));
    },

    async savePubliclyViewableChange(workout: Workout) {
      const responseData = (await this.workoutsStore.updateWorkout({
        workout,
        attributes: workout,
      })) as Workout;
      const message =
        responseData.publicly_viewable ?
          'Workout is now publicly viewable.'
        : 'Workout is now private.';
      Toastify({
        text: message,
        position: 'center',
        duration: 1800,
      }).showToast();
    },
  },
});
</script>
