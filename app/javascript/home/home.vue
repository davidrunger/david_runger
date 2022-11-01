<template lang='pug'>
#app-root.sans-serif.mb3
  #home.flex.flex-column.relative.vh-100.items-center.justify-around.font-white-dark.p4.bg-black
    .spacer.flex-grow-1
    //- HACK: add `data-section=''` so that we will clear the selected nav element when scrolled to
    //- the top of the page
    #headline-container.flex-grow-1(data-section='')
      #headline-name.monospace.font-blue-light.border-bottom.border-gray.pb-2
        span David Runger
      #headline-subtitle.sans-serif.font-size-4.light Full stack web developer
    header#header.flex-grow-1.flex.justify-between.bg-black.col-12.relative
      .font-size-2.js-link.js-scroll-top.ml3
        a#logo.monospace.font-blue-light.opacity-animated.opacity-0(href='#home')
          | David Runger
      nav#nav.sans-serif.flex.justify-around.absolute.mr4
        a.nav-link(href='#about')
          span.ptb-1 About
        a.nav-link(href='#skills')
          span.ptb-1 Skills
        a.nav-link(href='#projects')
          span.ptb-1 Projects
        a.nav-link(href='#resume')
          span.ptb-1 Resume
        a.nav-link(href='#contact')
          span.ptb-1 Contact
      .toggleable-menu
        .line-container
          .line
          .line
          .line
        .clearfix.header-height-spacer
        input.menu-toggle(type='checkbox' ref='menu-toggle-checkbox')
        .mobile-nav.dvh-100
          ul
            li #[a(href='#about' @click='collapseMobileMenu') About]
            li #[a(href='#skills' @click='collapseMobileMenu') Skills]
            li #[a(href='#projects' @click='collapseMobileMenu') Projects]
            li #[a(href='#resume' @click='collapseMobileMenu') Resume]
            li #[a(href='#contact' @click='collapseMobileMenu') Contact]
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
import ParallaxImage from './components/parallax_image.vue';
import * as positionListener from './scripts/position_listener';
import About from './components/about.vue';
import Contact from './components/contact.vue';
import Projects from './components/projects.vue';
import Resume from './components/resume.vue';
import Skills from './components/skills.vue';

export default {
  components: {
    About,
    Contact,
    ParallaxImage,
    Projects,
    Resume,
    Skills,
  },

  methods: {
    collapseMobileMenu() {
      this.$refs['menu-toggle-checkbox'].checked = false;
    },

    setScrollToFragmentTimeouts() {
      if (window.location.hash) {
        const fragmentTarget = document.getElementById(window.location.hash.slice(1));
        if (fragmentTarget) {
          // retarget scrolling to the element several times. earlier timeouts are so that we
          // scroll there as quickly as possible. later timeouts are because adjustments to the DOM
          // might be changing the scroll position of the target element as the page renders. stop
          // after 850 ms because at that point the user has a reasonable expectation to have full
          // control over their scroll position.
          [0, 150, 320, 500, 850].forEach((timeoutMilliseconds) => {
            setTimeout(() => {
              fragmentTarget.scrollIntoView();
            }, timeoutMilliseconds);
          });
        }
      }
    },
  },

  mounted() {
    this.setScrollToFragmentTimeouts();

    positionListener.init();

    const logo = document.getElementById('logo');
    new Waypoint.Inview({ // eslint-disable-line no-undef
      element: document.getElementById('home'),
      enter() {
        logo.classList.add('opacity-0');
        logo.classList.remove('opacity-1');
      },
      exited() {
        setTimeout(() => {
          logo.classList.add('opacity-1');
          logo.classList.remove('opacity-0');
        }, 0);
      },
    });
  },

  props: {},
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

#header {
  position: fixed;
  // performance hint to create a new compositor layer, so we don't re-paint on scroll
  will-change: transform;
  top: 0;
  z-index: 1;
  height: $header-height;
  line-height: $header-height;

  #nav {
    width: 500px;
    right: 0;

    @media screen and (max-width: $small-screen-breakpoint) {
      display: none;
    }

    a.nav-link {
      color: $gray-light;

      &.active {
        color: $white-dark;
      }

      &:hover {
        color: white;
      }

      span {
        border-bottom-width: 2px;
        border-bottom-style: solid;
        transition: border-bottom-color 1s ease-out;
      }

      &.active span {
        border-bottom-color: rgba($white-dark, 80%);
      }

      &:not(.active) span {
        border-bottom-color: rgba($white-dark, 0%);
      }
    }
  }
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

.toggleable-menu {
  display: none;

  @media screen and (max-width: $small-screen-breakpoint) {
    display: block;
  }
}

.header-height-spacer {
  height: $header-height;
}

.line-container {
  float: right;
  margin-top: 11px;
  margin-right: 20px;
  z-index: 10;
  position: relative;

  .line {
    width: 30px;
    height: 2px;
    margin: 7px 0;
    background-color: white;
  }
}

input.menu-toggle[type="checkbox"] {
  position: absolute;
  top: 8px;
  right: 12px;
  width: 40px;
  height: 38px;
  cursor: pointer;
  opacity: 0;
  z-index: 11;
}

.mobile-nav {
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  padding-top: 80px;
  text-align: center;
  background: #111;
  transition: transform 0.3s;
  transform: translate(0, -100%);

  ul {
    list-style: none;
    padding: 0;
  }

  li a {
    color: #b5b6be;
    display: block;
    padding: 25px 20px;
    font-size: 25px;

    &:hover {
      color: white;
    }
  }
}

input:checked + .mobile-nav {
  transform: translate(0, 0);
}
</style>
