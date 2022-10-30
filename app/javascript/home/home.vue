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
    header#header.flex-grow-1.flex.bg-black.col-12.relative
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

  HomeSection(section='about', title='About me', :renderHeadingManually='true')
    template(v-slot:default='slotProps')
      .sm-flex.row-reverse
        .flex-2.mt1
          PerformantImage.center.mt1.mb3(
            imageClass='about-image'
            alt='A picture of me'
            :lazy='true'
          )
            source(type='jpg' src='~img/david.jpg')
            source(type='webp' src='~img/david.webp')

        .flex-3.p2.sm-px4
          SectionHeader(:title='slotProps.title')

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

  ParallaxImage(variant='macbook-2')

  HomeSection(section='skills', title='Skills')
    table
      tbody
        SkillRow(
          name='Babel'
          details='Allowing us to safely use modern JavaScript features.'
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
          details='Because looking good is half the battle!'
        )
        SkillRow(
          name='Dokku'
          details='An open-source alternative to Heroku. (This site runs on Dokku!)'
        )
          template(v-slot:image)
            img(src='~img/dokku.svg' alt='Dokku')
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
          details=
          `
            Where software teams and the open source community collaborate. GitHub Actions are
            great!
          `
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
          details=
          `
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
          details=
          `
            Lodash brings a lot of the concision, convenience, and clarity that I love about Ruby to
            the front end.
          `
        )
          template(v-slot:image)
            img(src='~img/lodash.svg' alt='Lodash')
        SkillRow(
          name='NodeJS'
          details=
          `
            The JavaScript ecosystem is a bit too "Wild West" for my taste, but Node and its
            ecosystem are essential parts of the modern web stack.
          `
        )
        SkillRow(
          name='PostgreSQL'
          details='A fast, rock-solid, open source SQL database.'
        )
        SkillRow(
          name='React'
          details=
          `
            Declarative rendering, component-based development, and one-way data flow make React a
            superior alternative to direct DOM manipulation for moderately (or highly) complex
            client-side apps.
          `
        )
        SkillRow(
          name='Redis'
          details='A fast in-memory database.'
        )
        SkillRow(
          name='RSpec'
          details='I love testing, and RSpec makes tests readable and easy to write.'
        )
          template(v-slot:image)
            PerformantImage(
              alt='RSpec'
              :lazy='true'
            )
              source(type='png' src='~img/rspec.png')
        SkillRow(
          name='Ruby'
          details='Ruby was designed for developer happiness, and it shows!'
        )
        SkillRow(
          name='Ruby on Rails'
          iconIdentifier='rails'
          details=
          `
            A web-development framework with a great ecosystem that makes development fast and fun.
            Rails's ActiveRecord ORM is superb.
          `
        )
        SkillRow(
          name='Sass'
          :wordmarkedIcon='false'
          details=
          `
            It's in the name - syntactically awesome style sheets. Why write CSS when you can write
            Sass? :)
          `
        )
        SkillRow(
          name='VueJS'
        )
          template(v-slot:details)
            span.
              VueJS is a great library for building front-end UX, and it has a great supporting
              ecosystem. I hope that its popularity continues to grow.
        SkillRow(
          name='Webpack'
          details=
          `
            A versatile and powerful build tool for all-things client-side. Hot code reloading
            really enhances the development experience.
          `
        )

  ParallaxImage(variant='macbook-1')

  HomeSection(section='projects' title='Projects')
    Project.mt3
      template(v-slot:title)
        span DavidRunger.com
      template(v-slot:technologies)
        span Rails 7, Vue 3
      template(v-slot:links)
        a(href='https://github.com/davidrunger/david_runger/') Source Code
      template(v-slot:overview)
        p.

          You are here, at #[a(href='https://davidrunger.com') davidrunger.com]! This is a
          playground for me to experiment with various web technologies, and where I host various
          apps that I have built for myself and my family:

        ul

          li.
            #[a(href='https://davidrunger.com/groceries') Groceries]* -
            the family grocery list, designed and built to be mobile-friendly for use on-the-go

          li.
            #[a(href='https://davidrunger.com/workout') Workout]* -
            an app for tracking workouts over time, and to stay on-pace within a workout

          li.
            #[a(href='https://davidrunger.com/logs') Logs]* -
            track whatever you want with various log types (text, number, duration, and/or counter)

          li.
            #[a(href='https://davidrunger.com/quizzes') Quizzes]* -
            a multi-person quiz app that uses ActionCable websockets for real-time interactivity

          li.
            #[a(href='https://davidrunger.com/check_ins') Check-ins]* -
            track how well your emotional needs are being met in your marriage/relationship

        p *Google login required

      template(v-slot:tech-list)
        ul
          li.
            A
            #[a(href='https://rubyonrails.org/') Rails 7]
            backend serves various
            #[a(href='https://vuejs.org/') Vue 3]
            front-end apps built with
            #[a(href='https://pugjs.org') Pug] templates, ES6 (via
            #[a(href='https://babeljs.io/') Babel]), and
            #[a(href='http://sass-lang.com/') Sass].
          li.
            #[a(href='https://pinia.vuejs.org/') Pinia] provides client-side state management.
          li.

            The excellent
            #[a(href='https://vite-ruby.netlify.app/guide/rails.html') Vite Rails]
            gem, in conjunction with Vue and Pinia, provides hot module replacement (HMR), creating
            an efficient and enjoyable development flow.
            Vite Rails also bundles the application JavaScript and CSS for
            production.

          li Google OAuth provides convenient and secure sign-in.
          li.
            #[a(href='https://github.com/railsware/js-routes') JsRoutes] allows the
            use of Rails named routes / path helpers on the client-side, too! :)
          li.
            #[a(href='https://element-plus.org/#/en-US') Element Plus] provides aesthetic and
            ready-to-use Vue UI components.
          li.
            #[a(href='http://basscss.com/') Basscss] provides CSS utility classes, so that a
            lot of styling can be done quickly and cleanly within the markup itself.
          li.
            #[a(href='https://github.com/features/actions') GitHub Actions] provides continuous
            integration (CI) testing and linting, as well as
            continuous deployment (CD) via integration with
            #[a(href='https://dokku.com/') Dokku] on a DigitalOcean host.
          li.
            Ruby code is linted by #[a(href='https://rubocop.org/') RuboCop],
            JavaScript by #[a(href='https://eslint.org/') ESLint],
            and stylesheets by #[a(href='https://stylelint.io/') Stylelint].
            #[a(href='https://github.com/presidentbeef/brakeman') Brakeman] checks for
            Rails security issues, and
            #[a(href='https://github.com/djezzzl/database_consistency') DatabaseConsistency]
            and
            #[a(href='https://github.com/jenseng/immigrant') Immigrant]
            help to ensure that the database is well-structured.

  ParallaxImage(variant='macbook-2')

  HomeSection.pb4(
    section='resume'
    title='Resume'
  )
    a.resume-button.block.center(href='/David-Runger-Resume.pdf') Download Resume (pdf)

  ParallaxImage(variant='macbook-1')

  HomeSection(section='contact', title='Contact me')
    p #[b Email:] #[a(href='mailto:davidjrunger@gmail.com') davidjrunger@gmail.com]
    p #[b LinkedIn:] #[a(href='https://linkedin.com/in/davidrunger') /in/davidrunger]
    p #[b GitHub:] #[a(href='https://github.com/davidrunger') @davidrunger]
</template>

<script>
import PerformantImage from '@/components/performant_image.vue';
import ParallaxImage from './components/parallax_image.vue';
import * as positionListener from './scripts/position_listener';
import HomeSection, { SectionHeader } from './components/home_section.vue';
import Project from './components/project.vue';
import SkillRow from './components/skill_row.vue';

export default {
  components: {
    HomeSection,
    SectionHeader,
    ParallaxImage,
    PerformantImage,
    Project,
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

@media (min-width: 40em) {
  .sm-flex {
    display: flex;
  }

  .sm-px4 {
    padding-left: var(--space-4);
    padding-right: var(--space-4);
  }
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

  position: relative;
  bottom: 30px;
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
