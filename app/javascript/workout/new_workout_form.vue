<template lang='pug'>
  div.m2
    vue-form.mt3(:state='formstate')
      h2.h2 New Workout
      .my1
        label
          | Minutes
          validate
            el-input(
              v-model.number='minutes'
              name='minutes'
              required
              type='number'
            )
      .my1
        label
          | Sets
          validate
            el-input(
              v-model.number='sets'
              name='sets'
              required
              type='number'
            )
      .my1.clearfix(v-for='(exercise, index) in exercises')
        .col.col-6
          label
            | Exercise
            validate
              el-input(
                v-model='exercise.name'
                :name='`exercise-${index}-name`'
                required
                type='text'
              )
        .col.col-6
          label
            | Reps
            validate
              el-input(
                v-model.number='exercise.reps'
                :name='`exercise-${index}-reps`'
                required
                type='number'
              )
      .my1.center
        el-button(
          @click='exercises.push({})'
        ) Add exercise
      .mt3.center
        el-button(
          type='primary'
          :disabled='formstate.$invalid'
          @click='initializeWorkout()'
        ) Initialize Workout!
    div.my2
      h2.h2 Previous workouts
      table(v-if='bootstrap.workouts.length')
        thead
          tr
            th Completed
            th Time (minutes)
            th Rep totals
            th Public
        tbody
          tr(v-for='workout in workoutsSortedByCreatedAtDesc')
            td {{workout.created_at | prettyTime}}
            td {{(workout.time_in_seconds / 60).toFixed(1)}}
            td {{JSON.stringify(workout.rep_totals).replace(/{|}|"/g, '').replace(/,/g, ', ')}}
            td
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
      return sortBy(this.bootstrap.workouts, 'created_at').reverse();
    },
  },

  data() {
    return {
      formstate: {},
      minutes: null,
      sets: null,
      exercises: [{}],
    };
  },

  filters: {
    prettyTime(timeString) {
      return strftime('%b %-d, %Y at %-l:%M%P', new Date(timeString));
    },
  },

  methods: {
    initializeWorkout() {
      this.$emit('workout-initialized', {
        minutes: this.minutes,
        sets: this.sets,
        exercises: this.exercises,
      });
    },

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
};
</script>

<style>
th {
  font-weight: bold;
}

th,
td {
  text-align: center;
}

ol {
  list-style-type: decimal;
}
</style>
