<template lang='pug'>
div
  .center.mb1
    .h5.gray.pt1 {{bootstrap.current_user.email}}
    log(
      v-for='log in bootstrap.logs'
      :key='log.name'
      :name='log.name'
      :log_id='log.id'
      :log_inputs='log.log_inputs'
      :log_entries='log.log_entries'
    )
    new-log-form
</template>

<script>
import NewLogForm from './components/new_log_form.vue';
import Log from './components/log.vue';

export default {
  components: {
    NewLogForm,
    Log,
  },
};
</script>
