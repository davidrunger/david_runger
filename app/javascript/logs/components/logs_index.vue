<template lang='pug'>
section
  ul
    li.log-link-container.m1.h2(v-for='log in logs')
      router-link.log-link(:to='{ name: "log", params: { slug: log.slug }}') {{log.name}}
</template>

<script>
import { mapState } from 'vuex';

export default {
  computed: {
    ...mapState([
      'logs',
    ]),
  },
};
</script>
