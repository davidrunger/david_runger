<template lang='pug'>
div
  #home.flex.flex-column.relative.vh-100.align-items-center.justify-content-space-around.background-black.font-white-dark.p-5
    .spacer.flex-grow-2
    #headline-container.flex-grow-1
      #headline-name.monospace.font-size-1.font-blue-light.pb-5.mb-5.border-b-1.border-gray-dark.pb-2
        span David Runger
      #headline-subtitle.font-size-3.light Full stack web developer
    header#header.flex-grow-1.flex.background-black.width-100.relative('data-scroll-header'=true)
      #header-name.font-size-4.pl-5.js-link.js-scroll-top
        a.monospace.font-blue-light(href='#home') David Runger
      nav#nav.flex.justify-content-space-around.absolute
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
    a.down-arrow-container.flex-grow-0(href='#about')
      i.fa.fa-angle-double-down(aria-hidden='true')

  HomeSection(section='about', title='About me', color-palette='PuBu')
    .flex
      .pr-6.text-center
        img.about-image(src='~img/david.jpg' alt='A picture of me')
      .about-me.prl-5
        p.

          I'm a full stack web developer at #[a(href='http://www.hired.com') Hired.com].


        p.

          I love the Ruby programming language, the Rails web development framework, and the RSpec
          testing library. These are well-designed tools (with healthy supporting ecosystems) that
          allow me to work efficiently and effectively, and to have fun doing it.

        p.

          Previously, I've been a high school math teacher, a long haul truck driver, a public bus
          driver, and a web development bootcamp teaching assistant at
          #[a(href='http://www.appacademy.io') App Academy].

  HomeSection(section='skills', title='Skills', color-palette='Purples')
    p.

      Of course, I also have a respectable grasp of other common web technologies like CSS
      (CSS3, SCSS), HTML (HAML), JSON, and HTTP, as well as basic web security practices.

    p.

      On the frontend, in addition to raw JavaScript (ES5, ES6, and CoffeeScript), most of my
      experience is with React/Redux and jQuery. For JavaScript testing, I have mostly used
      Jasmine and Karma.

    p.

      I'm also currently building some side projects with Vue.js; it's unfortunate that this
      library isn't gaining more traction with companies in the United States.

    p.

      Some other tools that I have professional experience with but not a deep mastery of are
      Elasticsearch,

  HomeSection(section='projects', title='Projects', color-palette='Blues')
    p.

      These are my projects.

  HomeSection(section='resume', title='Resume', color-palette='PuRd')
    p.

      This is my resume.

  HomeSection(section='contact', title='Contact me', color-palette='GnBu')
    p.

      This is how to contact me.
</template>

<script>
import SmoothScroll from 'smooth-scroll/dist/js/smooth-scroll.min';
import _ from 'lodash';

import * as positionListener from './scripts/position_listener';
import HomeSection from './components/section.vue';

const COLOR_PALETTE_SEEDS = [1, 6, 7, 11, 12, 15];

export default {
  components: {
    HomeSection,
  },

  data() {
    return {
      trianglifySeeds: _.shuffle(COLOR_PALETTE_SEEDS),
    };
  },

  mounted() {
    positionListener.init();
    new SmoothScroll('a[href*="#"]'); // eslint-disable-line no-new
  },
};
</script>

<style lang='scss' scoped>
@import '~css/variables';

#header {
  line-height: 56px;
  z-index: 1;

  #header-name {
    opacity: 0;
  }

  #nav a {
    color: $gray-light;

    &:hover {
      color: white;
    }
  }

  &:not(.fixed-top) {
    .nav-link.active {
      span {
        border-bottom: none;
      }
    }
  }

  &.fixed-top {
    position: fixed;
    height: 56px;
    top: 0;

    #header-name {
      opacity: 1;
      animation: delayed-fade-in $transition-medium;
    }

    #nav {
      width: 500px;
      right: 0;
      transform: translateX(0);
    }
  }
}

#nav {
  width: 700px;
  max-width: 100%;
  transition: all $transition-medium;
  // center via right and translateX so we can animate from
  // center-aligned to right-aligned and vice versa
  right: 50%;
  transform: translateX(50%);

  @media screen and (max-width:600px) {
    display: none;
  }
}

.nav-link.active span {
  border-bottom: 4px solid gray;
}

.down-arrow-container {
  width: 50px;
  height: 50px;
  color: $black-light;
  background: $gray-light;
  border-radius: 50%;
  text-align: center;
  line-height: 50px;
  font-size: 30px;
  padding: 2px 0 0 2px;
  box-shadow: 0 2px 5px 0 rgba(0,0,0,0.3);
  margin-bottom: 30px; // needs to be big enough to psh above header when clicking 1st section
}
</style>
