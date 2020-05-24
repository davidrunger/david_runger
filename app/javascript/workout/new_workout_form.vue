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
        tbody
          tr(v-for='workout in bootstrap.workouts')
            td {{workout.created_at | prettyTime}}
            td {{(workout.time_in_seconds / 60).toFixed(1)}}
            td {{JSON.stringify(workout.rep_totals).replace(/{|}|"/g, '').replace(/,/g, ', ')}}
      div(v-else) None
</template>

<script>
import strftime from 'strftime';

export default {
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
