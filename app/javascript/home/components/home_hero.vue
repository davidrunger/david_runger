<template lang='pug'>
#home.flex.flex-col.relative.vh-100.items-center.justify-around.p-16.bg-neutral-950(
  ref="homeRef"
)
  .spacer.flex-grow-1
  #headline-container.flex-grow-1(data-section='home')
    #headline-name.monospace.text-blue-300.border-b-2.border-indigo-200
      | David Runger
    .pt-4.text-4xl.text-right.text-neutral-100
      | Full stack web developer

  HomeHeader

  a.flex.justify-center.items-center.down-arrow-container.rounded-full.mb-8(href='#about')
    //- hat tip to https://codepen.io/postor/pen/mskxI for a starting point for this
    svg(class='arrow' viewBox='0 0 24 14')
      path(d='M0 0 L12 12 L24 0')
</template>

<script lang='ts'>
import { ref } from 'vue';
import { useIntersectionObserver } from '@vueuse/core';

import { useHomeStore } from '@/home/store';
import HomeHeader from './home_header.vue';

export default {
  components: {
    HomeHeader,
  },

  data() {
    return {
      homeStore: useHomeStore(),
    };
  },

  setup() {
    const homeRef = ref(null);
    const homeStore = useHomeStore();

    useIntersectionObserver(
      homeRef,
      ([{ isIntersecting }]) => {
        homeStore.homeIsVisible = isIntersecting;
      },
    );

    return {
      homeRef,
    };
  },
};
</script>

<style lang='scss' scoped>
@import "css/variables";

#headline-name {
  font-size: 80px;

  @media screen and (max-width: $small-screen-breakpoint) {
    font-size: 65px;
  }
}

.down-arrow-container {
  $size: 50px;

  position: relative;
  bottom: 30px;
  width: $size;
  height: $size;
  line-height: $size;
  background: $gray-light;
  font-size: 30px;
  padding: 2px 0 0 2px; // nudges the arrow icon into the right place
}

.arrow {
  width: 24px;
}

.arrow path {
  stroke: #333;
  fill: transparent;
  stroke-width: 2px;
}
</style>
