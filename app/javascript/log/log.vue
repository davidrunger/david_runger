<template lang='pug'>
div
  div {{bootstrap.current_user.email}}
  weight-chart(:data='weightChartMetadata')
  vue-form(@submit.prevent='postWeightLog' :state='formstate')
    validate
      el-input(
        placeholder='Weight'
        type='number'
        v-model='newWeightLogWeight'
        name='newWeightLogWeight'
        required
      )
    el-input(
      value='Add'
      type='submit'
      :disabled='formstate.$invalid'
    )
</template>

<script>
import { mapState } from 'vuex';

import WeightChart from './components/weight_chart.vue';

export default {
  components: {
    WeightChart,
  },

  computed: {
    ...mapState([
      'weightLogs',
    ]),

    weightLogsToChartData() {
      return this.weightLogs.map(weightLog => {
        return {
          t: weightLog.created_at,
          y: weightLog.weight,
        };
      })
    },

    weightChartMetadata() {
      return {
        datasets: [{
          label: 'Weight',
          fill: false,
          data: this.weightLogsToChartData,
        }],
      };
    },
  },

  data() {
    return {
      formstate: {},
      newWeightLogWeight: '',
    };
  },

  methods: {
    postWeightLog() {
      if (this.formstate.$invalid) return;

      const payload = {
        weight_log: {
          weight: this.newWeightLogWeight,
        },
      };
      this.$http.post(this.$routes.api_weight_logs_path(), payload).then(() => {
        this.newWeightLogWeight = '';
      });
    },
  },
};
</script>

<style scoped>
div {
  font-family: sans-serif;
}
</style>
