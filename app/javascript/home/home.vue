<template lang='pug'>
#app-root.sans-serif
  #home.flex.flex-column.relative.vh-100.items-center.justify-around.font-white-dark.p4.bg-black
    .spacer.flex-grow-1
    //- HACK: add `data-section=''` so that we will clear the selected nav element when scrolled to
    //- the top of the page
    #headline-container.flex-grow-1(data-section='')
      #headline-name.monospace.font-blue-light.border-bottom.border-gray.pb-2
        span David Runger
      #headline-subtitle.sans-serif.font-size-4.light Full stack web developer
    header#header.flex-grow-1.flex.bg-black.col-12.relative
      .font-size-2.js-link.js-scroll-top.ml3
        a#logo.monospace.font-blue-light.opacity-animated.opacity-0(
          href='#home',
          style='display: none;'
        ) David Runger
      nav#nav.sans-serif.flex.justify-around.absolute.mr4
        a.nav-link(href='#about')
          span.ptb-1 About
        a.nav-link(href='#skills')
          span.ptb-1 Skills
        a.nav-link(href='#resume')
          span.ptb-1 Resume
        a.nav-link(href='#contact')
          span.ptb-1 Contact
    a.down-arrow-container.center.circle.mb3(href='#about')
      //- hat tip to https://codepen.io/postor/pen/mskxI for a starting point for this
      svg(class='arrow')
        path(d='M0 0 L12 12 L24 0')

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-1

  HomeSection(section='about', title='About me', :renderHeadingManually='true')
    template(v-slot:default='slotProps')
      .flex
        .flex-2.mr4.pr2
          HomeSectionHeader(:title='slotProps.title')

          p I'm a full stack web developer.

          p.
            I love the Ruby programming language, the Rails web development framework, and the RSpec
            testing library. These are well-designed tools with strong supporting ecosystems that
            allow me to work efficiently and to have fun doing it.
          p.
            I've been a software engineer and support engineer at
            #[a(href='https://hired.com') Hired], a web development bootcamp teaching assistant at
            #[a(href='http://www.appacademy.io') App&nbsp;Academy], a high school math teacher, a
            public bus driver, and a long haul truck driver.

        .flex-1
          PerformantImage(imageClass='about-image' alt='A picture of me' lazy=true)
            source(type='jpg' src='~img/david.jpg')
            source(type='webp' src='~img/david.webp')

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-2

  HomeSection(section='skills', title='Skills')
    table
      tbody
        SkillRow(
          name='Babel'
          details='For that sweet, sweet ES6 syntax.'
          devIconStyle='background: #f5db55'
          :wordmarkedIcon='false'
          :coloredIcon='false'
        )
        SkillRow(
          name='Confluence / JIRA'
          details='A quality tool for organizing an agile team.'
          iconIdentifier='confluence'
        )
        SkillRow(
          name='CSS3'
          details='Because looking good is half the battle! Love that flexbox. :)'
        )
        SkillRow(
          name='Elasticsearch'
          details='A fast, powerful, and flexible search backend.'
        )
          template(v-slot:image)
            img(src='~img/elasticsearch.svg' alt='Elasticsearch')
        SkillRow(
          name='Git'
          details='The standard in version control.'
        )
        SkillRow(
          name='GitHub'
          details='I have performed and received many, many code reviews via GitHub.'
        )
        SkillRow(
          name='Heroku'
          details="Doing (some of) the devops, so you don't have to."
        )
        SkillRow(
          name='HTML5'
          details='The building block of the Internet!'
        )
        SkillRow(
          name='Jasmine'
          details='I love testing, and Jasmine is a great JavaScript testing framework.'
        )
        SkillRow(
          name='JavaScript'
          details=`
            A flexible language, essential for any modern web app. ES6 (plus lodash to fill in some
            utility functions) makes JavaScript coding pretty enjoyable.
          `
          :wordmarkedIcon='false'
        )
        SkillRow(
          name='jQuery'
          details='DOM querying and manipulation made easy, with a huge plugin ecosystem.'
        )
        SkillRow(
          name='Lodash'
          details=`
            I adore Lodash. It brings a lot of the concision and clarity that I love about Ruby to
            the front end.
          `
        )
          template(v-slot:image)
            img(src='~img/lodash.svg' alt='Lodash')
        SkillRow(
          name='NodeJS'
          details=`
            The JavaScript ecosystem is still a bit too "Wild West" for my taste, but Node and its
            ecosystem are important parts of the modern web stack.
          `
        )
        SkillRow(
          name='PostgreSQL'
          details=`
            A fast, rock-solid, open source SQL database. I am really grateful for this tool.
          `
        )
        SkillRow(
          name='React'
          details=`
            Declarative rendering, component-based development, and one-way data flow make React a
            superior alternative to direct DOM manipulation for moderately (or highly) complex
            client-side apps.
          `
        )
        SkillRow(
          name='Redis'
          details=`
            An amazingly fast in-memory database. My main exposure has been via the Sidekiq
            job-processing library.
          `
        )
        SkillRow(
          name='RSpec'
        )
          template(v-slot:details)
            span.
              I #[em.italic love] testing. RSpec makes tests readable and easy to write.
          template(v-slot:image)
            PerformantImage(alt='RSpec' lazy=true)
              source(type='png' src='~img/rspec.png')
        SkillRow(
          name='Ruby'
          details='Ruby was designed for developer happiness, and it shows!'
        )
        SkillRow(
          name='Ruby on Rails'
          iconIdentifier='rails'
        )
          template(v-slot:details)
            span.
              I ❤️&nbsp;Rails: a web-development framework with a great ecosystem that makes
              development fast and fun. Rails's ActiveRecord ORM is superb.
        SkillRow(
          name='Sass'
          details=`
            It's in the name - syntactically awesome style sheets. Why write CSS when you can write
            Sass? :)
          `
          :wordmarkedIcon='false'
        )
        SkillRow(
          name='VueJS'
        )
          template(v-slot:details)
            span.
              I think that Vue is one of the best client-side libraries out there, and I hope that
              its popularity continues to grow.
        SkillRow(
          name='Webpack'
        )
          template(v-slot:details)
            span.
              A versatile and powerful build tool for all-things client-side. Hot code reloading
              really enhances the development experience.

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-1

  HomeSection(section='resume', title='Resume')
    a.resume-button.block.center(href='/David-Runger-Resume.pdf') Download Resume (pdf)

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-2

  HomeSection(section='contact', title='Contact me')
    p #[b Email:] #[a(href='mailto:davidjrunger@gmail.com') davidjrunger@gmail.com]
    p #[b LinkedIn:] #[a(href='https://linkedin.com/in/davidrunger') /in/davidrunger]
    p #[b GitHub:] #[a(href='https://github.com/davidrunger') @davidrunger]
</template>

<script>
import PerformantImage from '@/components/performant_image.vue';
import * as positionListener from './scripts/position_listener';
import HomeSection, { Header as HomeSectionHeader } from './components/home_section.vue';
import SkillRow from './components/skill_row.vue';

export default {
  components: {
    HomeSection,
    HomeSectionHeader,
    PerformantImage,
    SkillRow,
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
    logo.addEventListener('transitionend', () => {
      if (window.getComputedStyle(logo).opacity === '0') {
        logo.style.display = 'none';
      }
    });
    new Waypoint.Inview({ // eslint-disable-line no-undef
      element: document.getElementById('home'),
      enter() {
        logo.classList.add('opacity-0');
        logo.classList.remove('opacity-1');
      },
      exited() {
        logo.style.display = 'inline';
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

p,
ul,
:deep(td) {
  margin: 15px auto;
  line-height: 25px;
}

p:first-of-type {
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

:deep(.about-image) {
  max-width: 100%;
  box-shadow: $gray-light 0 2px 5px;
}

.down-arrow-container {
  $size: 50px;

  width: $size;
  height: $size;
  line-height: $size;
  background: $gray-light;
  font-size: 30px;
  padding: 2px 0 0 2px; // nudges the arrow icon into the right place
}

.resume-button {
  width: 240px;
  height: 60px;
  line-height: 56px;
  background-color: rgba(0, 0, 0, 72%);
  border: 2px solid #000;
  border-radius: 3px;
  box-shadow: #000 0 0 15px -4px;
  color: #ebebeb;

  &:hover {
    background-color: rgba(20, 20, 20, 72%);
    color: white;
    transition: 0.3s;
  }
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
