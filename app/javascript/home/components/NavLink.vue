<template lang="pug">
a.nav-link(
  :href="`#${section}`"
  :class="{ active }"
  @click="scrollToSection"
)
  span {{ linkText || prettyName }}
</template>

<script setup lang="ts">
import { capitalize } from 'es-toolkit';
import { computed } from 'vue';
import { string } from 'vue-types';

import { useHomeStore } from '@/home/store';

import { setScrollToFragmentTimeouts } from '../scroll_to_fragment';

const props = defineProps({
  linkText: string().def(''),
  section: string().isRequired,
});

const homeStore = useHomeStore();

const active = computed((): boolean => {
  return homeStore.activeSection === props.section;
});

const prettyName = computed((): string => {
  return capitalize(props.section);
});

function scrollToSection() {
  homeStore.registerClickedSection(props.section);
  setScrollToFragmentTimeouts(props.section);
}
</script>

<style lang="scss" scoped>
a.nav-link.nav-link {
  color: var(--gray-light);

  &:hover {
    color: white;
  }

  &.active {
    color: rgb(var(--white-dark-rgb));

    span {
      border-bottom-color: rgb(var(--white-dark-rgb), 0.8);
    }
  }

  span {
    border-bottom: 2px solid rgb(var(--white-dark-rgb), 0);
    transition: border-bottom-color 0.5s;
  }
}
</style>
