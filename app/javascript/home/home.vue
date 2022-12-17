<!-- eslint-disable max-len -->
<template lang='pug'>
#app-root.sans-serif.mb3
  #home.flex.flex-column.relative.vh-100.items-center.justify-around.font-white-dark.p4.bg-black(ref="homeRef")
    .spacer.flex-grow-1
    //- HACK: add `data-section=''` so that we will clear the selected nav element when scrolled to
    //- the top of the page
    #headline-container.flex-grow-1(data-section='')
      #headline-name.monospace.font-blue-light.border-bottom.border-gray.pb-2
        span David Runger
      #headline-subtitle.sans-serif.font-size-4.light Full stack web developer

    HomeHeader

    a.down-arrow-container.center.circle.mb3(href='#about')
      //- hat tip to https://codepen.io/postor/pen/mskxI for a starting point for this
      svg(class='arrow')
        path(d='M0 0 L12 12 L24 0')

  ParallaxImage(
    v-if='!$is_mobile_device'
    variant='macbook-1'
  )
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

<script>
import { ref } from 'vue';
import { useIntersectionObserver } from '@vueuse/core';

import { useHomeStore } from '@/home/store';
import About from './components/about.vue';
import Contact from './components/contact.vue';
import HomeHeader from './components/home_header.vue';
import ParallaxImage from './components/parallax_image.vue';
import Projects from './components/projects.vue';
import Resume from './components/resume.vue';
import Skills from './components/skills.vue';

export default {
  components: {
    About,
    Contact,
    HomeHeader,
    ParallaxImage,
    Projects,
    Resume,
    Skills,
  },

  data() {
    return {
      homeStore: useHomeStore(),
    };
  },

  methods: {
    setScrollToFragmentTimeouts() {
      if (window.location.hash) {
        const fragmentTarget = document.getElementById(window.location.hash.slice(1));
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
    },
  },

  mounted() {
    this.setScrollToFragmentTimeouts();
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

#app-root {
  letter-spacing: 0.2px;
  font-weight: 300;

  @media (max-width: 750px) {
    font-size: 15px;
  }

  @media (max-width: 550px) {
    font-size: 14px;
  }
}

:deep(b) {
  font-weight: 600;
}

:deep(p),
:deep(ul),
:deep(td) {
  margin: 15px auto;
  line-height: 25px;
}

:deep(p:first-of-type) {
  margin-top: 0;
}

#headline-name {
  font-size: 80px;

  @media screen and (max-width: $small-screen-breakpoint) {
    font-size: 65px;
  }
}

#headline-subtitle {
  text-align: right;
  padding-top: 6px;
}

:deep(.box-shadow) {
  box-shadow: $gray-light 0 2px 5px;
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
  height: 24px;
  position: relative;
  top: 7px;
}

.arrow path {
  stroke: #333;
  fill: transparent;
  stroke-width: 2px;
}
</style>
