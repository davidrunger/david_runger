<template lang='pug'>
  div
    .my2
      .h1(v-if='timer') Time Elapsed: {{timeElapsed}}
      div(v-else)
        button(
          @click='startWorkout'
        ) Start timer
    table
      tr
        th Set
        th Time
        th(v-for='exercise in exercises') {{exercise.name}}
      tr(v-for='(set, index) in sets')
        td {{set}}
        td {{interval * (set - 1) | minutesAsTime}}
        th(v-for='exercise in exercises') {{(index + 1) * exercise.reps}}
</template>

<script>
import { Timer } from 'easytimer.js';

export default {
  computed: {
    interval() {
      return this.minutes / (this.sets - 1);
    },
  },

  data() {
    return {
      timeElapsed: null,
      timer: null,
    };
  },

  filters: {
    minutesAsTime(minutesAsDecimalNumber) {
      const wholeMinutes = Math.floor(minutesAsDecimalNumber);
      const seconds = Math.floor(60 * (minutesAsDecimalNumber - wholeMinutes));
      const paddedSeconds = (seconds < 10) ? `0${seconds}` : `${seconds}`;
      return `${wholeMinutes}:${paddedSeconds}`;
    },
  },

  methods: {
    startWorkout() {
      this.timer = new Timer();
      this.timeElapsed = '00:00:00';

      this.timer.start();
      this.timer.addEventListener('secondsUpdated', () => {
        this.timeElapsed = this.timer.getTimeValues().toString();
      });
    },
  },

  props: {
    exercises: {
      type: Array,
      required: true,
    },
    minutes: {
      type: Number,
      required: true,
    },
    sets: {
      type: Number,
      required: true,
    },
  },
};
</script>
