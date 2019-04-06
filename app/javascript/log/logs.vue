<template lang='pug'>
div
  .center.mb1
    .h5.gray.pt1 {{bootstrap.current_user.email}}
    log-selector
    log(
      v-if='selectedLog'
      :key='selectedLog.name'
      :name='selectedLog.name'
      :log_id='selectedLog.id'
      :log_inputs='selectedLog.log_inputs'
      :log_entries='selectedLog.log_entries'
    )
    hr.silver.m3
    el-collapse(v-model='expandedPanelNames')
      el-collapse-item(title = 'Create new log' name='new-log-form')
        new-log-form
</template>

<script>
import { mapGetters, mapState } from 'vuex';

import NewLogForm from './components/new_log_form.vue';
import Log from './components/log.vue';
import LogSelector from './components/log_selector.vue';

export default {
  components: {
    Log,
    LogSelector,
    NewLogForm,
  },

  computed: {
    ...mapGetters([
      'selectedLog',
    ]),

    ...mapState([
      'selectedLogName',
    ]),
  },

  created() {
    document.addEventListener('keydown', (event) => {
      if ((event.key === 'k') && (event.metaKey == true)) {
        this.$store.commit('showModal', { modalName: 'log-selector' });
      }
    })
  },

  data() {
    return {
      expandedPanelNames: [],
    };
  },
};
</script>

<style scoped>
/deep/ .el-collapse-item {
  [role='tab']:focus,
  [role='button']:focus {
    outline: none;
  }
}
</style>
