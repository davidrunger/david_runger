<template lang='pug'>
div
  .center.mb1
    .h5.gray.pt1 {{bootstrap.current_user.email}}
    log-selector
    router-view(:key='$route.fullPath').m3
    el-collapse(v-model='expandedPanelNames')
      el-collapse-item(title = 'Create new log' name='new-log-form')
        new-log-form
</template>

<script>
import { mapGetters, mapState } from 'vuex';

import NewLogForm from './components/new_log_form.vue';
import LogSelector from './components/log_selector.vue';

export default {
  components: {
    LogSelector,
    NewLogForm,
  },

  computed: {
    ...mapGetters([
      'selectedLog',
    ]),

    ...mapState([
      'logs',
      'selectedLogName',
    ]),
  },

  created() {
    // If we are viewing a specific log, we want to ensure that the log entries for that log are
    // fetched first, so delay 10ms.
    // Otherwise (i.e. if viewing index), fetch all entries immediately.
    const delayBeforeFetchingAllLogs = this.selectedLog ? 10 : 0;
    setTimeout(() => {
      this.$store.dispatch('fetchAllLogEntries');
    }, delayBeforeFetchingAllLogs);

    document.addEventListener('keydown', (event) => {
      if ((event.key === 'k') && (event.metaKey == true)) {
        this.$store.commit('showModal', { modalName: 'log-selector' });
      }
    });
  },

  data() {
    return {
      expandedPanelNames: [],
    };
  },
};
</script>

<style lang='scss'>
body {
  background: black;
  color: #e0e0e0;
}

li.log-link-container {
  // specify the height so that changing the font on hover size doesn't push other links up/down
  height: 26px;
}

a.log-link {
  color: #e0e0e0;
  font-size: 100%;
  position: relative;
  transition: 0.2s;

  &:hover {
    font-size: 110%;
  }
}

.el-collapse-item {
  [role='tab']:focus,
  [role='button']:focus {
    outline: none;
  }
}

.el-button {
  background: black;

  &:focus,
  &:hover {
    background: black;
  }
}

input[type=text],
textarea.el-textarea__inner,
.el-input input.el-input__inner,
.el-input.is-disabled input.el-input__inner {
  background: black;
}

textarea.el-textarea__inner {
  color: #eee;
}

.el-input.is-disabled input.el-input__inner {
  color: gray;
}

.el-input input.el-input__inner {
  color: white;
}
</style>
