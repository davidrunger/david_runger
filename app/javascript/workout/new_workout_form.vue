<template lang='pug'>
  div
    vue-form(:state='formstate')
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
</template>

<script>
export default {
  data() {
    return {
      formstate: {},
      minutes: null,
      sets: null,
      exercises: [{}],
    };
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
