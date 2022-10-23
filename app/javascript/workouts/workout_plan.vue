<template lang='pug'>
.center.pb3
  .py2
    el-switch(
      v-model='editMode'
      active-text='Edit mode'
    )
    el-switch.ml2(
      v-model='soundEnabled'
      active-text='Sound'
    )
    .h1(v-if='timer') Time Elapsed: {{secondsAsTime(secondsElapsed)}}
    .mt1(v-else)
      button(
        @click='startWorkout'
      ) Start timer
  .flex.justify-center
    table
      thead
        tr
          th Set
          th(v-if='editMode') Base Time
          th(v-if='editMode') Time Adjustment
          th.time-column #[span(v-if='editMode') Final] Time
          th(v-for='exercise in exercises') {{exercise.name}}
      tbody
        tr(
          v-for='(setCount, index) in numberOfSets'
          :class='tableRowClass(index)'
        )
          td {{setCount}}
          td(v-if='editMode') {{secondsAsTime(intervalInSeconds * index)}}
          td(v-if='editMode')
            input(
              type='text'
              v-model.number='setsArray[index].timeAdjustment'
              :disabled='index <= currentRoundIndex'
            )
          td(:class='nextRoundCountdownClass(index)') {{timeColumnValue(index)}}
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
        tr
          td
          td(v-if='editMode')
          td(v-if='editMode')
          td
          td(v-for='exercise in exercises') {{repTotalsForWorkout[exercise.name]}}
  .my2
    button(@click='saveWorkout') Mark workout as complete!

  ConfirmWorkoutModal(
    :timeInSeconds='secondsElapsed'
    :repTotals='repTotalsAsOfCurrentRound'
  )
</template>

<script>
import { Timer } from 'easytimer.js';
import { cloneDeep, includes } from 'lodash-es';

import { useModalStore } from '@/shared/modal/store';
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
      modalStore: useModalStore(),
      secondsElapsed: 0,
      setsArray: this.initialSetsArray(),
      soundEnabled: true,
      timer: null,
    };
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

    nextRoundCountdownClass(index) {
      if (index !== this.currentRoundIndex + 1) return '';

      if (this.secondsUntilNextRound <= 10) {
        return ['red', 'bold'];
      } else if (this.secondsUntilNextRound <= 30) {
        return 'orange';
      } else {
        return '';
      }
    },

    saveWorkout() {
      this.timer.stop();
      this.modalStore.showModal({ modalName: 'confirm-workout' });
    },

    say(message, volume = 1) {
      if (!this.soundEnabled) return;

      const utterance = new SpeechSynthesisUtterance(message);
      utterance.volume = volume;
      window.speechSynthesis.speak(utterance);
    },

    secondsAsTime(seconds) {
      const minutesAsDecimal = seconds / 60;
      const wholeMinutes = Math.floor(minutesAsDecimal);
      const secondsRemainder = Math.floor(seconds - (60 * wholeMinutes));
      const paddedSeconds =
        (secondsRemainder < 10) ? `0${secondsRemainder}` : `${secondsRemainder}`;
      return `${wholeMinutes}:${paddedSeconds}`;
    },

    startWorkout() {
      this.timer = new Timer();
      this.currentRoundIndex = 0;

      this.timer.start();
      this.say('Starting workout', 0); // "say" it silently to enable speech synthesis on iOS
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

    timeColumnValue(index) {
      if (this.currentRoundIndex + 1 === index) {
        return `-${this.secondsAsTime(this.secondsUntilNextRound)}`;
      } else {
        return this.secondsAsTime(
          this.intervalInSeconds * index +
            this.cumulativeTimeAdjustment(index, this.timeAdjustments),
        );
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

<style scoped>
.time-column {
  /* fix the width because otherwise it changes as the countdown time changes */
  width: 75px;
}

table {
  border-spacing: 0;
}

table tr:first-of-type th {
  border-bottom: 1px solid gray;
}

tbody tr:last-of-type td {
  border-top: 1px solid gray;
}

td input {
  width: 50px;
}
</style>
