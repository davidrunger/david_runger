<template lang="pug">
#app-root.mb-8.font-sans
  HomeHero

  ParallaxImage(
    v-if="!isMobileDevice()"
    variant="macbook-1"
  )
  //- This is necessary so that the #home section will scroll out of the page when clicking the down arrow.
  .h-10.bg-black(v-else)

  About

  ParallaxImage(variant="macbook-2")

  Skills

  ParallaxImage(variant="macbook-1")

  Projects

  ParallaxImage(variant="macbook-2")

  Resume

  ParallaxImage(variant="macbook-1")

  Contact
</template>

<script setup lang="ts">
import { onMounted } from 'vue';

import { useExternalLinkTracking } from '@/lib/composables/useExternalLinkTracking';
import { useScrollTracking } from '@/lib/composables/useScrollTracking';
import { isMobileDevice } from '@/lib/isMobileDevice';
import { renderBootstrappedToasts } from '@/lib/vueToasts';

import About from './components/About.vue';
import Contact from './components/Contact.vue';
import HomeHero from './components/HomeHero.vue';
import ParallaxImage from './components/ParallaxImage.vue';
import Projects from './components/Projects.vue';
import Resume from './components/Resume.vue';
import Skills from './components/Skills.vue';
import { setScrollToFragmentTimeouts } from './scrollToFragment';
import { useManualScrollTracking } from './useManualScrollTracking';

renderBootstrappedToasts();
useExternalLinkTracking();
useScrollTracking();
useManualScrollTracking();

onMounted(() => {
  setScrollToFragmentTimeouts();
});
</script>

<style lang="scss">
:root {
  // NOTE: This corresponds to the total height of the header in _logged_in_header.html.haml .
  --user-header-height: 32px;
  --main-bg-color: var(--color-neutral-950);
  --main-text-color: var(--color-neutral-100);
}

.logged-out {
  --user-header-height: 0px;
}

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

@layer base {
  body {
    p,
    ul,
    td {
      margin: 1em auto;
      line-height: 25px;
    }
  }
}

p:first-of-type {
  margin-top: 0;
}

.box-shadow {
  box-shadow: var(--gray-light) 0 2px 5px;
}
</style>
