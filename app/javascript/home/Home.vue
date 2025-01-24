<template lang="pug">
#app-root.sans-serif.mb-8
  HomeHero

  ParallaxImage(v-if='!isMobileDevice()' variant='macbook-1')
  //- this is necessary so that the #home section will scroll out of page when clicking down arrow
  .bg-black(v-else style='height: 40px')

  About

  ParallaxImage(variant='macbook-2')

  Skills

  ParallaxImage(variant='macbook-1')

  Projects

  ParallaxImage(variant='macbook-2')

  Resume

  ParallaxImage(variant='macbook-1')

  Contact
</template>

<script setup lang="ts">
import { onMounted } from 'vue';

import { isMobileDevice } from '@/lib/is_mobile_device';

import About from './components/About.vue';
import Contact from './components/Contact.vue';
import HomeHero from './components/HomeHero.vue';
import ParallaxImage from './components/ParallaxImage.vue';
import Projects from './components/Projects.vue';
import Resume from './components/Resume.vue';
import Skills from './components/Skills.vue';

onMounted(() => {
  setScrollToFragmentTimeouts();
});

function setScrollToFragmentTimeouts() {
  if (window.location.hash) {
    const fragmentTarget = document.getElementById(
      window.location.hash.slice(1),
    );
    if (fragmentTarget) {
      // retarget scrolling to the element several times. earlier timeouts are so that we
      // scroll there as quickly as possible. later timeouts are because adjustments to the DOM
      // might be changing the scroll position of the target element as the page renders. stop
      // after 850 ms because at that point the user has a reasonable expectation to have full
      // control over their scroll position.
      for (const timeoutMilliseconds of [0, 150, 320, 500, 850]) {
        setTimeout(() => {
          fragmentTarget.scrollIntoView();
        }, timeoutMilliseconds);
      }
    }
  }
}
</script>

<style lang="scss">
@use 'css/variables' as *;

#app-root {
  letter-spacing: 0.2px;
  font-weight: 300;

  @media (width <= 750px) {
    font-size: 15px;
  }

  @media (width <= 550px) {
    font-size: 14px;
  }
}

b {
  font-weight: 600;
}

p,
ul,
td {
  margin: 15px auto;
  line-height: 25px;
}

p:first-of-type {
  margin-top: 0;
}

.box-shadow {
  box-shadow: var(--gray-light) 0 2px 5px;
}
</style>
