<template lang='pug'>
section
  ul
    li.log-link-container.m1.h2(v-for='log in logs')
      router-link.log-link(:to='{ name: "log", params: { slug: log.slug }}') {{log.name}}
  el-collapse(v-model='expandedPanelNames')
    el-collapse-item(title = 'Create new log' name='new-log-form')
      NewLogForm
</template>

<script>
import { mapState } from 'vuex';

import NewLogForm from './new_log_form.vue';

export default {
  components: {
    NewLogForm,
  },

  computed: {
    ...mapState([
      'logs',
    ]),
  },

  data() {
    return {
      expandedPanelNames: [],
    };
  },

  title() {
    return 'Logs - David Runger';
  },
};
</script>
