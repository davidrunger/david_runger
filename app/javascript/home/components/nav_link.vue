<template lang="pug">
a.nav-link(
  :href='`#${section}`'
  :class='{ active }'
  @click='homeStore.registerClickedSection(section)'
)
  span {{linkText || prettyName}}
</template>

<script lang="ts">
import { capitalize } from 'lodash-es';

import { useHomeStore } from '@/home/store';

export default {
  computed: {
    active(): boolean {
      return this.homeStore.activeSection === this.section;
    },

    prettyName(): string {
      return capitalize(this.section);
    },
  },

  data() {
    return {
      homeStore: useHomeStore(),
    };
  },

  props: {
    linkText: {
      type: String,
      required: false,
    },
    section: {
      type: String,
      required: true,
    },
  },
};
</script>

<style lang="scss" scoped>
@import 'css/variables';

a.nav-link.nav-link {
  color: $gray-light;

  &:hover {
    color: white;
  }

  &.active {
    color: $white-dark;

    span {
      border-bottom-color: rgba($white-dark, 80%);
    }
  }

  span {
    border-bottom: 2px solid rgba($white-dark, 0%);
    transition: border-bottom-color 0.5s;
  }
}
</style>
