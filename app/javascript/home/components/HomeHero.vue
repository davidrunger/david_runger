<template lang="pug">
#home.flex.flex-col.relative.h-screen.items-center.justify-around.p-16.bg-neutral-950(
  ref="homeRef"
)
  .spacer.grow
  hgroup#headline-container.grow(data-section='home')
    h1#headline-name.monospace.font-normal.text-blue-300.leading-normal
      | David Runger
    .stripe.stripe-1
    .stripe.stripe-2
    .stripe.stripe-3
    .stripe.stripe-4
    p.pt-4.text-4xl.text-right.text-neutral-100
      | Full stack web developer

  HomeHeader

  a.flex.justify-center.items-center.down-arrow-container.rounded-full.mb-8(href='#about')
    //- hat tip to https://codepen.io/postor/pen/mskxI for a starting point for this
    svg(class='arrow' viewBox='0 0 24 14')
      path(d='M0 0 L12 12 L24 0')
</template>

<script setup lang="ts">
import { useIntersectionObserver } from '@vueuse/core';
import { ref } from 'vue';

import { useHomeStore } from '@/home/store';

import HomeHeader from './HomeHeader.vue';

const homeRef = ref(null);
const homeStore = useHomeStore();

useIntersectionObserver(homeRef, ([{ isIntersecting }]) => {
  homeStore.homeIsVisible = isIntersecting;
});
</script>

<style lang="scss" scoped>
@use 'css/sass_variables' as *;

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
  background: var(--gray-light);
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

.stripe {
  height: 3px;
  margin: 8px auto;
}

.stripe-1 {
  background: linear-gradient(90deg, #72b7b2, var(--color-neutral-950));
}

.stripe-2 {
  background: linear-gradient(90deg, var(--color-neutral-950), #e45756, #e45756);
}

.stripe-3 {
  background: linear-gradient(90deg, var(--color-neutral-950), #f58518, #f58518);
}

.stripe-4 {
  background: linear-gradient(90deg, var(--color-neutral-950), #eeca3b, #eeca3b);
}
</style>
