<template lang="pug">
a.nav-link(
  :href='`#${section}`'
  :class='{ active }'
  @click='homeStore.registerClickedSection(section)'
)
  span {{linkText || prettyName}}
</template>

<script setup lang="ts">
import { capitalize } from 'lodash-es';
import { computed } from 'vue';

import { useHomeStore } from '@/home/store';

const props = defineProps({
  linkText: {
    type: String,
    required: false,
    default: null,
  },
  section: {
    type: String,
    required: true,
  },
});

const homeStore = useHomeStore();

const active = computed((): boolean => {
  return homeStore.activeSection === props.section;
});

const prettyName = computed((): string => {
  return capitalize(props.section);
});
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
