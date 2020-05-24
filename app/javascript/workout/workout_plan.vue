<template lang='pug'>
  div
    .my2
      .h1(v-if='timer') Time Elapsed: {{timeElapsedString}}
      div(v-else)
        button(
          @click='startWorkout'
        ) Start timer
      el-switch(
        v-model='editMode'
        active-text='Edit mode'
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
</template>

<script>
import { Timer } from 'easytimer.js';
import { get } from 'lodash';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';

export default {
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
      timeElapsedString: null,
      secondsElapsed: 0,
      setsArray: this.initialSetsArray(),
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

    initialSetsArray() {
      return Array(...Array(this.sets)).map(_ => ({ timeAdjustment: 0 }));
    },

    saveWorkout() {
      this.timer.stop();

      const repTotals = {};
      this.exercises.forEach(({ name, reps }) => {
        repTotals[name] = reps * (this.currentRoundIndex + 1);
      });

      const repTotalsConfirmed = window.confirm(
        `Please confirm that you completed this workout.
        Minutes: ${(this.secondsElapsed / 60).toFixed(1)}
        Reps: ${JSON.stringify(repTotals)}`.replace(/\n +/g, '\n'),
      );
      if (repTotalsConfirmed) {
        this.$http.post(this.$routes.api_workouts_path(), {
          workout: {
            time_in_seconds: this.secondsElapsed,
            rep_totals: repTotals,
          },
        }).then((response) => {
          if (response.status === 201) {
            Toastify({
              text: 'Workout completion logged successfully!',
              className: 'success',
              position: 'center',
              duration: 2500,
            }).showToast();
          }
        }).catch((error) => {
          const errorMessage = get(error, 'response.data.error', 'Something went wrong');
          Toastify({
            text: errorMessage,
            className: 'error',
            position: 'center',
            duration: 2500,
          }).showToast();
        });
      } else {
        Toastify({
          text: 'Workout was not saved (because you cancelled it).',
          className: 'error',
          position: 'center',
          duration: 2500,
        }).showToast();
      }
    },

    startWorkout() {
      this.timer = new Timer();
      this.timeElapsedString = '00:00:00';
      this.currentRoundIndex = 0;

      this.timer.start();
      this.timer.addEventListener('secondsUpdated', () => {
        this.timeElapsedString = this.timer.getTimeValues().toString();
        this.secondsElapsed = this.timer.getTotalTimeValues().seconds;

        if (this.secondsElapsed >= this.nextRoundStartAtSeconds) {
          this.currentRoundIndex++;
        }
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
