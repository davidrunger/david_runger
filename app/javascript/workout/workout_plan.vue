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
        th
      tr(
        v-for='(set, index) in sets'
        :class='tableRowClass(index)'
      )
        td {{set}}
        td {{intervalInMinutes * (set - 1) | minutesAsTime}}
        td(v-for='exercise in exercises') {{(index + 1) * exercise.reps}}
        td(v-show='index === currentRoundIndex + 1')
            | Starts
            | in #[span(:class='{red: (secondsUntilNextRound <= 10)}') {{timeUntilNextRoundString}}]
</template>

<script>
import { Timer } from 'easytimer.js';

export default {
  computed: {
    intervalInMinutes() {
      return this.minutes / (this.sets - 1);
    },

    intervalInSeconds() {
      return this.intervalInMinutes * 60;
    },

    nextRoundStartAtSeconds() {
      return Math.floor((this.currentRoundIndex + 1) * this.intervalInSeconds);
    },

    secondsUntilNextRound() {
      return this.nextRoundStartAtSeconds - this.secondsElapsed;
    },
  },

  created() {
    this.nextRoundStartTimer = new Timer();
    this.nextRoundStartTimer.start({
      countdown: true,
      startValues: {
        seconds: this.secondsUntilNextRound,
      },
    });
    this.timeUntilNextRoundString = this.nextRoundStartTimer.getTimeValues().toString();
  },

  data() {
    return {
      currentRoundIndex: 0,
      timeElapsedString: null,
      timeUntilNextRoundString: null,
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
      this.currentRoundIndex = 0;

      this.timer.start();
      this.nextRoundStartTimer.reset();
      this.timer.addEventListener('secondsUpdated', () => {
        this.timeElapsedString = this.timer.getTimeValues().toString();
        this.secondsElapsed = this.timer.getTotalTimeValues().seconds;

        if (this.secondsElapsed === this.nextRoundStartAtSeconds) {
          this.currentRoundIndex++;
          this.nextRoundStartTimer = new Timer();
          this.nextRoundStartTimer.start({
            countdown: true,
            startValues: {
              seconds: this.secondsUntilNextRound,
            },
          });
          this.nextRoundStartTimer.addEventListener('secondsUpdated', () => {
            this.timeUntilNextRoundString = this.nextRoundStartTimer.getTimeValues().toString();
          });
        }
      });
      this.nextRoundStartTimer.addEventListener('secondsUpdated', () => {
        this.timeUntilNextRoundString = this.nextRoundStartTimer.getTimeValues().toString();
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
