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
          td(
            :class='nextRoundCountdownClasses(index)'
          ) {{timeColumnValue(index)}}
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

<script lang='ts'>
import { PropType } from 'vue';
import { Timer } from 'easytimer.js';
import { cloneDeep } from 'lodash-es';

import { assert } from '@/shared/helpers';
import { useModalStore } from '@/shared/modal/store';
import ConfirmWorkoutModal from './confirm_workout_modal.vue';
import { Exercise } from './types';

type SetObject = {
  exercises: Array<Exercise>
  timeAdjustment: number
}

export default {
  components: {
    ConfirmWorkoutModal,
  },

  computed: {
    cumulativeTimeAdjustment() {
      return (index: number, timeAdjustments: Array<number>) => {
        let cumulativeTotal = 0;
        for (let i = 0; i <= index; i++) {
          cumulativeTotal += timeAdjustments[i];
        }
        return cumulativeTotal;
      };
    },

    intervalInMinutes(): number {
      if (this.numberOfSets === 1) return 0;

      return this.minutes / (this.numberOfSets - 1);
    },

    intervalInSeconds(): number {
      return this.intervalInMinutes * 60;
    },

    nextRoundStartAtSeconds(): number {
      return (
        Math.floor((this.currentRoundIndex + 1) * this.intervalInSeconds) +
          this.cumulativeTimeAdjustment(this.currentRoundIndex + 1, this.timeAdjustments)
      );
    },

    repTotalsAsOfCurrentRound() {
      const repTotalsAsOfCurrentRound: { [key:string]: number } = {};
      for (const { name: exerciseName } of this.exercises) {
        repTotalsAsOfCurrentRound[exerciseName] =
          this.setsArray.slice(0, this.currentRoundIndex + 1).
            reduce((total: number, setObject: SetObject) => {
              const exerciseObject =
                setObject.exercises.find((exercise: Exercise) => exercise.name === exerciseName);
              return total + assert(exerciseObject).reps;
            }, 0);
      }
      return repTotalsAsOfCurrentRound;
    },

    repTotalsForWorkout() {
      const repTotalsForWorkout: { [key:string]: number } = {};
      for (const { name: exerciseName } of this.exercises) {
        repTotalsForWorkout[exerciseName] =
          this.setsArray.reduce((total: number, setObject: SetObject) => {
            const exerciseObject =
              setObject.exercises.find(exercise => exercise.name === exerciseName);
            return total + assert(exerciseObject).reps;
          }, 0);
      }
      return repTotalsForWorkout;
    },

    secondsUntilNextRound(): number {
      return this.nextRoundStartAtSeconds - this.secondsElapsed;
    },

    timeAdjustments(): Array<number> {
      return this.setsArray.map((setObject: SetObject) => setObject.timeAdjustment);
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
      timer: null as null | Timer,
    };
  },

  methods: {
    confirmUnloadWorkoutInProgress(event: BeforeUnloadEvent) {
      if (
        (this.secondsElapsed > 0) &&
          (this.currentRoundIndex < (this.numberOfSets - 1)) &&
          this.timer &&
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
      } else if ([10, 20, 30].includes(this.secondsUntilNextRound)) {
        this.say(`${this.secondsUntilNextRound} seconds`);
      }
    },

    initialSetsArray() {
      return Array(...Array(this.numberOfSets)).map(_ => ({
        timeAdjustment: 0,
        exercises: cloneDeep(this.exercises),
      }));
    },

    nextRoundCountdownClasses(index: number) {
      if (index !== this.currentRoundIndex + 1) return '';

      const classes = ['bold'];
      if (this.secondsUntilNextRound <= 10) {
        classes.push('red');
      } else if (this.secondsUntilNextRound <= 30) {
        classes.push('orange');
      }

      return classes;
    },

    saveWorkout() {
      if (this.timer) this.timer.stop();
      this.modalStore.showModal({ modalName: 'confirm-workout' });
    },

    say(message: string, volume = 1) {
      if (!this.soundEnabled) return;

      const utterance = new SpeechSynthesisUtterance(message);
      utterance.volume = volume;
      window.speechSynthesis.speak(utterance);
    },

    secondsAsTime(seconds: number) {
      if (seconds <= 0) return '0:00';

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
        if (!this.timer) return;
        this.secondsElapsed = this.timer.getTotalTimeValues().seconds;
        this.handleSecondElapsed();
      });
    },

    tableRowClass(index: number) {
      if (index < this.currentRoundIndex) {
        return 'bg-green'; // past round
      } else if (index === this.currentRoundIndex) {
        return 'bg-aqua'; // active round
      } else {
        return ''; // future round
      }
    },

    timeColumnValue(index: number) {
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
      type: Array as PropType<Array<Exercise>>,
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
