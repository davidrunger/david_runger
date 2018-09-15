<template lang='pug'>
div
  .h2.my2 {{name}}
  log-data-display(:log_inputs='log_inputs', :log_entries='log_entries')
  new-log-entry-form(:log_id='log_id' :log_inputs='log_inputs')
</template>

<script>
import DurationTimeseries from './data_renderers/duration_timeseries.vue'
import IntegerTimeseries from './data_renderers/integer_timeseries.vue'
import NewLogEntryForm from './new_log_entry_form.vue'

const PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING = {
  duration: DurationTimeseries,
  integer: IntegerTimeseries,
};

const LogDataDisplay = {
  functional: true,
  render (h, context) {
    if (context.props.log_inputs.length === 1) {
      const logInput = context.props.log_inputs[0];
      const publicType = logInput.public_type;
      const dataLabel = logInput.label;
      const DataRenderer = PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING[publicType];

      return (
        <DataRenderer log_entries={context.props.log_entries} data_label={dataLabel} />
      );
    }
  },
}

export default {
  components: {
    LogDataDisplay,
    NewLogEntryForm,
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
    name: {
      type: String,
      required: true,
    },
  },
};
</script>
