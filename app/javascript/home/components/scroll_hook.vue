<template lang='pug'>
.js-scroll-hook.absolute(ref='scrollHookRef')
</template>

<script>
import { ref } from 'vue';
import { useIntersectionObserver } from '@vueuse/core';

import { useHomeStore } from '@/home/store';

export default {
  props: {
    section: {
      type: String,
      required: true,
    },
  },

  setup(props) {
    const scrollHookRef = ref(null);
    const homeStore = useHomeStore();

    useIntersectionObserver(
      scrollHookRef,
      ([{ isIntersecting }]) => {
        if (isIntersecting) {
          homeStore.addSectionShowing(props.section);
        } else {
          homeStore.removeSectionShowing(props.section);
        }
      },
    );

    return {
      scrollHookRef,
    };
  },
};
</script>

<style>
.js-scroll-hook {
  top: 23vh; /* needs to be small enough that bottom section (contact) can be scrolled into view */
  bottom: 25vh;
}
</style>
