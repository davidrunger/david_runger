<template lang='pug'>
div
  .h2.my2 Weight
  .flex.justify-center.mb1
    div(style='width: 400px')
      vue-form.flex.px1(@submit.prevent='postWeightLog' :state='formstate')
        validate.flex-1.mr1
          el-input(
            placeholder='Weight'
            type='number'
            v-model='newWeightLogWeight'
            name='newWeightLogWeight'
            required
          )
        el-input.flex-0(
          type='submit'
          value='Add'
          :disabled='postingWeightLog || formstate.$invalid'
        )
  weight-chart(:data='weightChartMetadata')
</template>

<script>
import { mapState } from 'vuex';

import WeightChart from './weight_chart.vue';

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
      postingWeightLog: false,
    };
  },

  methods: {
    postWeightLog() {
      if (this.formstate.$invalid) return;

      this.postingWeightLog = true;

      const payload = {
        weight_log: {
          weight: this.newWeightLogWeight,
        },
      };
      this.$http.post(this.$routes.api_weight_logs_path(), payload).then(() => {
        this.newWeightLogWeight = '';
        window.location.reload();
      });
    },
  },
};
</script>
