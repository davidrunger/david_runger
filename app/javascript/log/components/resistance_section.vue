<template lang='pug'>
div
  .h2.my2 Resistance
  .flex.justify-center.mb1
    div(style='max-width: 600px')
      vue-form.flex.px1(@submit.prevent='postResistanceLog' :state='formstate')
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
        el-input.flex-0(type='submit' value='Log' :disabled='formstate.$invalid')
</template>

<script>
export default {
  data() {
    return {
      formstate: {},
      newResistanceLog: {
        exerciseId: null,
        count: null,
      },
    };
  },

  methods: {
    postResistanceLog() {
      if (this.formstate.$invalid) return;

      const payload = {
        exercise_count_log: {
          exercise_id: this.newResistanceLog.exerciseId,
          count: this.newResistanceLog.count,
        },
      };
      this.$http.post(this.$routes.api_exercise_count_logs_path(), payload).then(() => {
        this.newResistanceLog = {};
      });
    },
  },
};
</script>
