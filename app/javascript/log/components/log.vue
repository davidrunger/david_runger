<template lang='pug'>
div
  h1.h2.mt3.mb1 {{name}}
  p.h5.mb2.description {{description}}
  log-data-display(:log_inputs='log_inputs', :log_entries='log_entries')
  new-log-entry-form(:log_id='log_id' :log_inputs='log_inputs')
  .mt1
    el-button(@click='destroyLastEntry') Delete last entry
</template>

<script>
import _ from 'lodash';

import DurationTimeseries from './data_renderers/duration_timeseries.vue'
import IntegerTimeseries from './data_renderers/integer_timeseries.vue'
import TextLog from './data_renderers/text_log.vue'
import NewLogEntryForm from './new_log_entry_form.vue'

const PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING = {
  duration: DurationTimeseries,
  integer: IntegerTimeseries,
  text: TextLog,
};

const LogDataDisplay = {
  functional: true,
  render (h, context) {
    if (context.props.log_inputs.length === 1) {
      const logInput = context.props.log_inputs[0];
      const publicType = logInput.public_type;
      const dataLabel = logInput.label;
      const DataRenderer = PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING[publicType];

      return h(DataRenderer, {
        props: {
          log_entries: context.props.log_entries,
          data_label: dataLabel,
        },
      });
    }
  },
}

export default {
  components: {
    LogDataDisplay,
    NewLogEntryForm,
  },

  methods: {
    destroyLastEntry() {
      var confirmation = confirm(
        `Are you sure that you want to delete the last entry from the ${this.name} log?`
      );
      if (confirmation === true) {
        const logEntryToDestroy = _(this.log_entries).sortBy('created_at').last();
        this.$http.
          delete(this.$routes.api_log_entry_path({ id: logEntryToDestroy.id })).
          then(() => window.location.reload());
      }
    },
  },

  props: {
    log_entries: {
      type: Array,
      required: true,
    },
    log_id: {
      type: Number,
      required: true,
    },
    log_inputs: {
      type: Array,
      required: true,
    },
    description: {
      type: String,
      required: false,
    },
    name: {
      type: String,
      required: true,
    },
  },
};
</script>

<style scoped>
.description {
  font-weight: 200;
}
</style>
