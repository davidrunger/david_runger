<template lang="pug">
.js-scroll-hook.absolute(ref="scrollHookRef")
</template>

<script setup lang="ts">
import { useIntersectionObserver } from '@vueuse/core';
import { ref } from 'vue';
import { string } from 'vue-types';

import { useHomeStore } from '@/home/store';

const props = defineProps({
  section: string().isRequired,
});

const scrollHookRef = ref(null);
const homeStore = useHomeStore();

useIntersectionObserver(scrollHookRef, ([{ isIntersecting }]) => {
  if (isIntersecting) {
    homeStore.addSectionShowing(props.section);
  } else {
    homeStore.removeSectionShowing(props.section);
  }
});
</script>

<style>
.js-scroll-hook {
  top: 23vh; /* needs to be small enough that bottom section (contact) can be scrolled into view */
  bottom: 25vh;
}
</style>
