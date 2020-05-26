<template lang='pug'>
div
  .my2
    .h1(v-if='timer') Time Elapsed: {{secondsElapsed | secondsAsTime}}
    div(v-else)
      button(
        @click='startWorkout'
      ) Start timer
    el-switch(
      v-model='editMode'
      active-text='Edit mode'
    )
    el-switch.ml2(
      v-model='soundEnabled'
      active-text='Sound'
    )
  table.my2
    thead
      tr
        th Set
        th(v-if='editMode') Base Time
        th(v-if='editMode') Time Adjustment
        th #[span(v-if='editMode') Final] Time
        th(v-for='exercise in exercises') {{exercise.name}}
        th
    tbody
      tr(
        v-for='(set, index) in sets'
        :class='tableRowClass(index)'
      )
        td {{set}}
        td(v-if='editMode') {{intervalInSeconds * (set - 1) | secondsAsTime}}
        td(v-if='editMode')
          input(
            type='text'
            v-model.number='setsArray[index].timeAdjustment'
            :disabled='index <= currentRoundIndex'
          )
        td.
          {{
            intervalInSeconds * (set - 1) +
              cumulativeTimeAdjustment(index, timeAdjustments) | secondsAsTime
          }}
        td(v-for='exercise in exercises') {{(index + 1) * exercise.reps}}
        td(v-show='index === currentRoundIndex + 1').
          Starts in
          #[span(:class='nextRoundCountdownClass') {{secondsUntilNextRound | secondsAsTime}}]
  .my2
    button(@click='saveWorkout') Mark workout as complete!

  ConfirmWorkoutModal(
    :timeInSeconds='secondsElapsed'
    :repTotals='repTotals'
  )
</template>

<script>
import { Timer } from 'easytimer.js';
import { includes } from 'lodash';

import ConfirmWorkoutModal from './confirm_workout_modal.vue';

export default {
  components: {
    ConfirmWorkoutModal,
  },

  computed: {
    cumulativeTimeAdjustment() {
      return (index, timeAdjustments) => {
        let cumulativeTotal = 0;
        for (let i = 0; i <= index; i++) {
          cumulativeTotal += timeAdjustments[i];
        }
        return cumulativeTotal;
      };
    },

    intervalInMinutes() {
      return this.minutes / (this.sets - 1);
    },

    intervalInSeconds() {
      return this.intervalInMinutes * 60;
    },

    nextRoundCountdownClass() {
      if (this.secondsUntilNextRound <= 10) {
        return ['red', 'bold'];
      } else if (this.secondsUntilNextRound <= 30) {
        return 'orange';
      } else {
        return '';
      }
    },

    nextRoundStartAtSeconds() {
      return (
        Math.floor((this.currentRoundIndex + 1) * this.intervalInSeconds) +
          this.cumulativeTimeAdjustment(this.currentRoundIndex + 1, this.timeAdjustments)
      );
    },

    repTotals() {
      const repTotals = {};
      this.exercises.forEach(({ name, reps }) => {
        repTotals[name] = reps * (this.currentRoundIndex + 1);
      });
      return repTotals;
    },

    secondsUntilNextRound() {
      return this.nextRoundStartAtSeconds - this.secondsElapsed;
    },

    timeAdjustments() {
      return this.setsArray.map(set => set.timeAdjustment);
    },
  },

  created() {
    window.addEventListener('beforeunload', this.confirmUnloadWorkoutInProgress);
  },

  data() {
    return {
      currentRoundIndex: 0,
      editMode: false,
      secondsElapsed: 0,
      setsArray: this.initialSetsArray(),
      soundEnabled: true,
      timer: null,
    };
  },

  filters: {
    secondsAsTime(seconds) {
      const minutesAsDecimal = seconds / 60;
      const wholeMinutes = Math.floor(minutesAsDecimal);
      const secondsRemainder = Math.floor(seconds - (60 * wholeMinutes));
      const paddedSeconds =
        (secondsRemainder < 10) ? `0${secondsRemainder}` : `${secondsRemainder}`;
      return `${wholeMinutes}:${paddedSeconds}`;
    },
  },

  methods: {
    confirmUnloadWorkoutInProgress(event) {
      if (
        (this.secondsElapsed > 0) &&
          (this.currentRoundIndex < (this.sets - 1)) &&
          this.timer.isRunning()
      ) {
        // ask the user to confirm that they want to leave the page
        event.preventDefault();
        event.returnValue = '';
        return '';
      } else {
        // allow the user to leave without confirming
        return undefined;
      }
    },

    handleSecondElapsed() {
      if (this.secondsElapsed >= this.nextRoundStartAtSeconds) {
        this.currentRoundIndex++;
        this.say('Go!');
      } else if (includes([10, 20, 30], this.secondsUntilNextRound)) {
        this.say(`${this.secondsUntilNextRound} seconds`);
      }
    },

    initialSetsArray() {
      return Array(...Array(this.sets)).map(_ => ({ timeAdjustment: 0 }));
    },

    saveWorkout() {
      this.timer.stop();
      this.$store.commit('showModal', { modalName: 'confirm-workout' });
    },

    say(message) {
      if (!this.soundEnabled) return;

      window.speechSynthesis.speak(new SpeechSynthesisUtterance(message));
    },

    startWorkout() {
      this.timer = new Timer();
      this.currentRoundIndex = 0;

      this.timer.start();
      this.timer.addEventListener('secondsUpdated', () => {
        this.secondsElapsed = this.timer.getTotalTimeValues().seconds;
        this.handleSecondElapsed();
      });
    },

    tableRowClass(index) {
      if (index < this.currentRoundIndex) {
        return 'bg-green'; // past round
      } else if (index === this.currentRoundIndex) {
        return 'bg-aqua'; // active round
      } else {
        return ''; // future round
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

<style>
th,
td {
  padding: 5px 10px;
}
</style>
