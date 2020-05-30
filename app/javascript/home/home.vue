<template lang='pug'>
div.font-nunito
  #home.flex.flex-column.relative.vh-100.items-center.justify-around.font-white-dark.p4.bg-black
    .spacer.flex-grow-1
    //- HACK: add `data-section=''` so that we will clear the selected nav element when scrolled to
    //- the top of the page
    #headline-container.flex-grow-1(data-section='')
      #headline-name.monospace.font-blue-light.pb-5.mb-5.border-bottom.border-gray.pb-2
        span David Runger
      #headline-subtitle.sans-serif.font-size-4.light Full stack web developer
    header#header.fixed-top.flex-grow-1.flex.bg-black.col-12.relative
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
        a.nav-link(href='#projects')
          span.ptb-1 Projects
        a.nav-link(href='#resume')
          span.ptb-1 Resume
        a.nav-link(href='#contact')
          span.ptb-1 Contact
    a.down-arrow-container.center.circle.mb3(href='#about')
      el-icon(name='arrow-down')

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-1

  HomeSection(section='about', title='About me', :renderHeadingManually='true')
    template(slot-scope='slotProps')
      .flex
        .flex-2.mr4.py1.pr2
          HomeSectionHeader(:title='slotProps.title')

          p I'm a full stack web developer.

          p.
            I love the Ruby programming language, the Rails web development framework, and the RSpec
            testing library. These are well-designed tools (with healthy supporting ecosystems) that
            allow me to work efficiently and to have fun doing it.
          p.
            Previously, I've been a software engineer and support engineer at
            #[a(href='https://hired.com') Hired], a web development bootcamp teaching assistant at
            #[a(href='http://www.appacademy.io') App Academy], a high school math teacher, a public
            bus driver, and a long haul truck driver.

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
          img(slot='image' src='~img/elasticsearch.svg' alt='Elasticsearch')
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
          img(slot='image' src='~img/lodash.svg' alt='Lodash')
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
          span(slot='details').
            I #[em.italic love] testing. RSpec makes tests readable and easy to write.
          PerformantImage(slot='image' alt='RSpec' imageStyle='height: 65px' lazy=true)
            source(type='png' src='~img/rspec.png')
        SkillRow(
          name='Ruby'
          details='Ruby was designed for developer happiness, and it shows!'
        )
        SkillRow(
          name='Ruby on Rails'
          iconIdentifier='rails'
        )
          span(slot='details').
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
          span(slot='details').
            I think that Vue is one of the best client-side frameworks/libraries out there, and I
            hope that its popularity continues to grow. I keep track of my grocery list using
            #[a(:href='$routes.groceries_path()') an app that I built with Vue].
        SkillRow(
          name='Webpack'
        )
          span(slot='details').
            A versatile and powerful build tool for all-things client-side.
            #[span.monospace webpack‑dev‑server] and hot code reloading really enhance the
            development experience.

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-1

  HomeSection(section='projects', title='Projects')
    Project
      span(slot='title') My Grocery List
      span(slot='technologies') Rails 6, Vue.js, Vuex, Nexmo SMS API
      div(slot='links')
        a(:href='this.$routes.groceries_path()') Live
        span #{' - '}
        a(
          href='https://github.com/davidrunger/david_runger/tree/master/app/javascript/groceries'
        ) GitHub
      PerformantImage(slot='image' alt='Groceries app' lazy=true)
        source(type='jpg' src='~img/groceries.jpg')
        source(type='webp' src='~img/groceries.webp')
      div(slot='overview')
        p.
          I choose not to own a smartphone (😱), and I eat the same few things week after week.
          With this in mind, I wanted an app that would help me to efficiently track and purchase
          groceries. Plus, I wanted an excuse to experiment with
          #[a(href='https://vuejs.org/') Vue.js]! So I built
          #[a(:href='this.$routes.groceries_path()') davidrunger.com/groceries].
        p.
          I use this app to keep track of which grocery items I need. Then, when it's time to go
          shopping, I text the grocery list to myself via the Nexmo SMS API, so that I can easily to
          refer to it on my "dumb" phone while I'm at the store.
      ul(slot='tech-list')
        li.
          A #[b Rails 6] back end serves a #[b Vue.js] front end application that's built with
          #[b #[a(href='https://pugjs.org') pug]] templates, ES6 (via
          #[b #[a(href='https://babeljs.io/') babel]]), and
          #[b #[a(href='http://sass-lang.com/') Sass]].
        li.
          Rails's #[b webpacker] gem provides #[b Hot Module Replacement] for
          #[i all] aspects of the frontend app (HTML, CSS, and JavaScript). This creates a
          super efficient and enjoyable development flow! 😄
        li #[b Google OAuth] provides convenient and secure sign-in
        li #[b Vuex] manages the application state
        li.
          Integrates with the #[b #[a(href='https://www.nexmo.com/?') Nexmo] SMS API], allowing
          users to text themselves a list of currently needed grocery items
        li.
          The excellent
          #[b #[a(href='https://github.com/cameronhimself/vue-drag-drop') vue-drag-drop]] library
          allows dragging an item from one store to another.
        li.
          The excellent #[b #[a(href='https://github.com/railsware/js-routes') js-routes]]
          library allows the use of Rails named routes / path helpers on the client-side, too! :)
        li.
          #[b #[a(href='http://element.eleme.io/#/en-US') Element]] provides pretty and ready-to-use
          Vue UI components.
        li.
          #[b #[a(href='http://basscss.com/') Basscss]] provides CSS utility classes, so that a lot
          of styling can be done in the markup itself.
        li.
          The official #[b #[a(href='https://vue-test-utils.vuejs.org/en/') vue-test-utils]] library
          facilitates Vue component unit testing. Tests are run using #[b Mocha],
          #[b headless Chrome], and "regular" (non-headless) Chrome.
        li.
          #[b Continuous integration (CI)] via Travis, which also provides
          #[b continuous deployment (CD)] via #[b Heroku] (which hosts the app)
        li.
          Ruby code is linted by #[b RuboCop], JavaScript by #[b ESLint], and stylesheets by
          #[b Stylelint].

    Project
      span(slot='title') Rosetta Code Languages Selector
      span(slot='technologies') Chrome Extension, Capybara integration tests
      div(slot='links')
        a(
          href='https://chrome.google.com/webstore/detail/rosetta-code-languages-se/icjinpkbplhheomciikehmieadoibljg'
        ) Live
        span #{' - '}
        a(href='https://github.com/davidrunger/rc-languages-selector') GitHub

      PerformantImage(slot='image' alt='Rosetta Code Languages Selector' lazy=true)
        source(type='png' src='~img/rc-languages-selector.png')
        source(type='webp' src='~img/rc-languages-selector.webp')

      div(slot='overview')
        p.
          #[a(href='http://rosettacode.org/wiki/Rosetta_Code') RosettaCode.org] is a great website
          for comparing programming languages and/or learning a new language based on others that
          you already know. However, for each sample programming task, there are so many
          implementations available in different languages that it can be difficult to find the code
          samples for the languages that you are focusing on. This extension solves that problem by
          only showing code samples for languages that you have specifically selected.

      ul(slot='tech-list')
        li.
          Comprehensive Capybara integration test suite allows for confident refactoring and
          feature extension.
        li.
          Custom testing solution mimics the Chrome Extension API by monkeypatching the Capybara
          library to automatically inject the extension's JavaScript and CSS assets into any page
          visited during an integration test.

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-2

  HomeSection(section='resume', title='Resume')
    a.resume-button.block.center(href='/David-Runger-Resume.pdf') Download Resume (pdf)

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-1

  HomeSection(section='contact', title='Contact me')
    p #[b Email:] #[a(href='mailto:davidjrunger@gmail.com') davidjrunger@gmail.com]
    p #[b LinkedIn:] #[a(href='https://linkedin.com/in/davidrunger') /in/davidrunger]
    p #[b GitHub:] #[a(href='https://github.com/davidrunger') @davidrunger]
</template>

<script>
import PerformantImage from 'components/performant_image.vue';

import * as positionListener from './scripts/position_listener';
import HomeSection, { Header as HomeSectionHeader } from './components/home_section.vue';
import Project from './components/project.vue';
import SkillRow from './components/skill_row.vue';

export default {
  components: {
    HomeSection,
    HomeSectionHeader,
    PerformantImage,
    Project,
    SkillRow,
  },

  mounted() {
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
@import url('https://fonts.googleapis.com/css?family=Nunito:400,700');
@import '~css/variables';

.font-nunito {
  font-family: 'Nunito', sans-serif;
}

p,
ul {
  margin: 15px auto;
  line-height: 20px;
}

p:first-of-type {
  margin-top: 0;
}

.project {
  /deep/ img {
    box-shadow: #c0c0c0 2px 2px 10px 0;
    border-radius: 3px;
    max-height: 300px;
    max-width: 90%;
  }

  ul {
    list-style: initial;

    li {
      margin: 4px 0 4px 20px;
    }

    li:last-of-type {
      margin-bottom: 0;
    }
  }
}

#headline-name {
  font-size: 80px;

  @media screen and (max-width: 600px) {
    font-size: 40px;
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

    @media screen and (max-width: 600px) {
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
        border-bottom-color: rgba($white-dark, 0.8);
      }

      &:not(.active) span {
        border-bottom-color: rgba($white-dark, 0);
      }
    }
  }
}

/deep/ .about-image {
  max-width: 100%;
  box-shadow: $gray-light 0 2px 5px;
}

.down-arrow-container {
  $size: 50px;

  width: $size;
  height: $size;
  line-height: $size;
  color: $black-light;
  background: $gray-light;
  font-size: 30px;
  padding: 2px 0 0 2px; // nudges the arrow icon into the right place
}

.resume-button {
  width: 240px;
  height: 60px;
  line-height: 56px;
  background-color: rgba(0, 0, 0, 0.72);
  border: 2px solid #000;
  border-radius: 3px;
  box-shadow: #000 0 0 15px -4px;
  color: #ebebeb;

  &:hover {
    background-color: rgba(20, 20, 20, 0.72);
    color: white;
    transition: 0.3s;
  }
}
</style>
