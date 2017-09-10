<template lang='pug'>
div
  .flex.flex-column.relative.vh-100.align-items-center.justify-content-space-around.background-black.font-white-dark.p-5
    .spacer
    #headline-container
      #headline-name.monospace.font-size-1.font-blue-medium.pb-5.mb-5.border-b-1.border-gray-dark.pb-2
        span David Runger
      #headline-subtitle.font-size-3.light Full stack web developer
    header#header.flex.background-black.width-100.relative('data-scroll-header'=true)
      #header-name.font-size-4.pl-5.js-link.js-scroll-top
        a.monospace.font-blue-medium(href='#') David Runger
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

  #main.prl-5

    hr#about.visibility-hidden
    section(data-section='about')
      h2.font-size-3 About me
      .flex
        .width-33.pr-5
          img.about-image(src='~img/david.jpg' alt='A picture of me')
        .width-66.about-me.prl-5
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

    hr#skills
    section(data-section='skills')
      h2.font-size-3 Skills

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

    hr#projects
    section(data-section='projects')
      h2.font-size-3 Projects

      p.

        These are my projects.

    hr#resume
    section(data-section='resume')
      h2.font-size-3 Resume

      p.

        This is my resume.

    hr#contact
    section(data-section='contact')
      h2.font-size-3 Contact me

      p.

        This is how to contact me.
</template>

<script>
import SmoothScroll from 'smooth-scroll/dist/js/smooth-scroll.min.js';

import * as positionListener from './position_listener';

export default {
  mounted() {
    positionListener.init();
    new SmoothScroll('a[href*="#"]', { offset: 54 });
  },
}
</script>

<style lang='scss' scoped>
@import '~css/variables';

#header {
  line-height: 56px;

  #header-name {
    opacity: 0;
  }

  #nav a {
    color: #cccccc;

    &:hover {
      color: white;
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
  justify-content: space-around;
  right: 50%;
  transform: translateX(50%);

  @media screen and (max-width:600px) {
    display: none;
  }
}

#main {
  max-width: 850px;
  margin: 0 auto;
}

.nav-link.active span {
  border-bottom: 4px solid gray;
}

.about-image {
  max-width: 100%;
  height: auto;
}

section {
  padding: 30px 0;

  h2 {
    padding-bottom: 30px;
  }

  p {
    padding-bottom: 25px;
  }
}
</style>
