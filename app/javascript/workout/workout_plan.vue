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
        v-for='(setCount, index) in numberOfSets'
        :class='tableRowClass(index)'
      )
        td {{setCount}}
        td(v-if='editMode') {{intervalInSeconds * index | secondsAsTime}}
        td(v-if='editMode')
          input(
            type='text'
            v-model.number='setsArray[index].timeAdjustment'
            :disabled='index <= currentRoundIndex'
          )
        td.
          {{
            intervalInSeconds * index +
              cumulativeTimeAdjustment(index, timeAdjustments) | secondsAsTime
          }}
        td(
          v-for='exercise in setsArray[index].exercises'
        )
          input(
            v-if='editMode'
            type='text'
            v-model.number='exercise.reps'
            :disabled='index <= (currentRoundIndex - 1)'
          )
          span(v-else) {{exercise.reps}}
        td(v-show='index === currentRoundIndex + 1').
          Starts in
          #[span(:class='nextRoundCountdownClass') {{secondsUntilNextRound | secondsAsTime}}]
      tr
        td
        td(v-if='editMode')
        td(v-if='editMode')
        td
        td(v-for='exercise in exercises') {{repTotalsForWorkout[exercise.name]}}
        td
  .my2
    button(@click='saveWorkout') Mark workout as complete!

  ConfirmWorkoutModal(
    :timeInSeconds='secondsElapsed'
    :repTotals='repTotalsAsOfCurrentRound'
  )
</template>

<script>
import { Timer } from 'easytimer.js';
import { cloneDeep, includes } from 'lodash';

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
      return this.minutes / (this.numberOfSets - 1);
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

    repTotalsAsOfCurrentRound() {
      const repTotalsAsOfCurrentRound = {};
      this.exercises.forEach(({ name: exerciseName }) => {
        repTotalsAsOfCurrentRound[exerciseName] =
          this.setsArray.slice(0, this.currentRoundIndex + 1).reduce((total, setObject) => {
            const exerciseObject =
              setObject.exercises.find(exercise => exercise.name === exerciseName);
            return total + exerciseObject.reps;
          }, 0);
      });
      return repTotalsAsOfCurrentRound;
    },

    repTotalsForWorkout() {
      const repTotalsForWorkout = {};
      this.exercises.forEach(({ name: exerciseName }) => {
        repTotalsForWorkout[exerciseName] =
          this.setsArray.reduce((total, setObject) => {
            const exerciseObject =
              setObject.exercises.find(exercise => exercise.name === exerciseName);
            return total + exerciseObject.reps;
          }, 0);
      });
      return repTotalsForWorkout;
    },

    secondsUntilNextRound() {
      return this.nextRoundStartAtSeconds - this.secondsElapsed;
    },

    timeAdjustments() {
      return this.setsArray.map(setObject => setObject.timeAdjustment);
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
          (this.currentRoundIndex < (this.numberOfSets - 1)) &&
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
      return Array(...Array(this.numberOfSets)).map(_ => ({
        timeAdjustment: 0,
        exercises: cloneDeep(this.exercises),
      }));
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
    numberOfSets: {
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

tbody tr:last-of-type td:not(:last-of-type) {
  border-top: 1px solid gray;
}

td input {
  width: 50px;
}
</style>
