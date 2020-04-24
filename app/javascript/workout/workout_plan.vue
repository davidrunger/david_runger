<template lang='pug'>
  div
    .my2
      .h1(v-if='timer') Time Elapsed: {{timeElapsedString}}
      div(v-else)
        button(
          @click='startWorkout'
        ) Start timer
    table
      tr
        th Set
        th Time
        th(v-for='exercise in exercises') {{exercise.name}}
      tr(
        v-for='(set, index) in sets'
        :class='tableRowClass(index)'
      )
        td {{set}}
        td {{intervalInMinutes * (set - 1) | minutesAsTime}}
        th(v-for='exercise in exercises') {{(index + 1) * exercise.reps}}
</template>

<script>
import { Timer } from 'easytimer.js';

export default {
  computed: {
    intervalInMinutes() {
      return this.minutes / (this.sets - 1);
    },
  },

  data() {
    return {
      timeElapsedString: null,
      secondsElapsed: 0,
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
      this.timeElapsedString = '00:00:00';

      this.timer.start();
      this.timer.addEventListener('secondsUpdated', () => {
        this.timeElapsedString = this.timer.getTimeValues().toString();
        this.secondsElapsed = this.timer.getTotalTimeValues().seconds;
      });
    },

    tableRowClass(index) {
      const secondsUntilRoundStart = Math.floor(this.intervalInMinutes * index * 60);
      const secondsUntilNextRoundStart = Math.floor(this.intervalInMinutes * (index + 1) * 60);
      if (secondsUntilRoundStart <= this.secondsElapsed) {
        if (this.secondsElapsed < secondsUntilNextRoundStart) {
          return 'bg-blue'; // active round
        } else {
          return 'bg-green'; // past round
        }
      } else {
        return 'bg-white'; // future round
      }
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
