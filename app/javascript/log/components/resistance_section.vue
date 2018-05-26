<template lang='pug'>
div
  .h2.my2 Resistance
  .flex.justify-center.mb1
    div(style='max-width: 600px')
      .h3.mt3.mb1 Log a set
      vue-form.flex.px1(@submit.prevent='postResistanceLog' :state='resistanceLogFormstate')
        validate.flex-1.mr1
          el-select(
            v-model='newResistanceLog.exerciseId'
            placeholder='Choose exercise'
            name='newResistanceLog.exerciseId'
            required
          )
            el-option(
              v-for='exercise in bootstrap.exercises'
              :key='exercise.id'
              :label='exercise.name'
              :value='exercise.id'
            )
        validate.flex-1.mr1
          el-input(
            placeholder='Count'
            type='number'
            v-model='newResistanceLog.count'
            name='newResistanceLog.count'
            required
          )
        el-input.flex-0(type='submit' value='Log' :disabled='resistanceLogFormstate.$invalid')
      .h3.mt3.mb1 Today's Exercise
      div {{JSON.stringify(bootstrap.exercise_counts_today || 'No exercises have been done today')}}
      .h3.mt3.mb1 Add a new exercise
      vue-form.flex.px1(@submit.prevent='postNewExercise' :state='newExerciseFormstate')
        validate.flex-1.mr1
          el-input(
            placeholder='Exercise name'
            type='input'
            v-model='newExercise.name'
            name='newExercise.name'
            required
          )
        el-input.flex-0(type='submit' value='Submit' :disabled='newExerciseFormstate.$invalid')
</template>

<script>
export default {
  data() {
    return {
      newExercise: {},
      newExerciseFormstate: {},
      newResistanceLog: {
        exerciseId: null,
        count: null,
      },
      resistanceLogFormstate: {},
    };
  },

  methods: {
    postNewExercise() {
      if (this.newExerciseFormstate.$invalid) return;

      const payload = {
        exercise: {
          name: this.newExercise.name,
        },
      };
      this.$http.post(this.$routes.api_exercises_path(), payload).then(() => {
        this.newExercise = {};
        window.location.reload();
      });
    },

    postResistanceLog() {
      if (this.resistanceLogFormstate.$invalid) return;

      const payload = {
        exercise_count_log: {
          exercise_id: this.newResistanceLog.exerciseId,
          count: this.newResistanceLog.count,
        },
      };
      this.$http.post(this.$routes.api_exercise_count_logs_path(), payload).then(() => {
        this.newResistanceLog = {};
        window.location.reload();
      });
    },
  },
};
</script>
