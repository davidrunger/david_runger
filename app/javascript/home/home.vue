<template lang='pug'>
div
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
        a.monospace.font-blue-light(href='#home') David Runger
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

  HomeSection(section='about', title='About me')
    .flex
      .about-me.flex-2.mr4.py1.pr2
        p.
          I'm a full stack web developer at #[a(href='http://www.hired.com') Hired].
        p.
          I love the Ruby programming language, the Rails web development framework, and the RSpec
          testing library. These are well-designed tools (with healthy supporting ecosystems) that
          allow me to work efficiently and effectively, and to have fun doing it.
        p.
          Previously, I've been a web development bootcamp teaching assistant at
          #[a(href='http://www.appacademy.io') App Academy], a high school math teacher, a public
          bus driver, and a long haul truck driver.

      .pr-6.flex-1.flex.items-center
        PerformantImage(imageClass='about-image' alt='A picture of me' lazy=true)
          source(type='jpg' src='~img/david.jpg')
          source(type='webp' src='~img/david.webp')

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-2

  HomeSection(section='skills', title='Skills')
    table
      tbody
        tr
          td #[i.devicon-babel-plain(style='background: #f5db55')]
          td Babel
          td For that sweet, sweet ES6 syntax.
        tr
          td #[i.devicon-confluence-plain-wordmark.colored]
          td Confluence / JIRA
          td A quality tool for organizing an agile team.
        tr
          td #[i.devicon-css3-plain-wordmark.colored]
          td CSS3
          td Because looking good is half the battle! Love that flexbox. :)
        tr
          td #[img(src='~img/elasticsearch.svg' alt='Elasticsearch')]
          td Elasticsearch
          td A fast, powerful, and flexible search backend.
        tr
          td #[i.devicon-git-plain-wordmark.colored]
          td Git
          td The standard in version control.
        tr
          td #[i.devicon-github-plain-wordmark.colored]
          td GitHub
          td I have performed and received many, many code reviews via GitHub.
        tr
          td #[i.devicon-heroku-plain-wordmark.colored]
          td Heroku
          td Doing (some of) the devops, so you don't have to.
        tr
          td #[i.devicon-html5-plain-wordmark.colored]
          td HTML5
          td The building block of the Internet!
        tr
          td #[i.devicon-jasmine-plain-wordmark.colored]
          td Jasmine
          td I love testing, and Jasmine is a great JavaScript testing framework.
        tr
          td #[i.devicon-javascript-plain.colored]
          td JavaScript
          td.
            A flexible language, essential for any modern web app. ES6 (plus lodash to fill in some
            utility functions) makes JavaScript coding pretty enjoyable.
        tr
          td #[i.devicon-jquery-plain-wordmark.colored]
          td jQuery
          td DOM querying and manipulation made easy, with a huge plugin ecosystem.
        tr
          td #[img(src='~img/lodash.svg' alt='Lodash')]
          td Lodash
          td.
            I adore Lodash. It brings a lot of the concision and clarity that I love about Ruby to
            the front end.
        tr
          td #[i.devicon-nodejs-plain-wordmark.colored]
          td NodeJS
          td.
            The JavaScript ecosystem is still a bit too "Wild West" for my taste, but Node and its
            ecosystem are important parts of the modern web stack.
        tr
          td #[i.devicon-postgresql-plain-wordmark.colored]
          td PostgreSQL
          td A fast, rock-solid, open source SQL database. I am really grateful for this tool.
        tr
          td #[i.devicon-react-plain-wordmark.colored]
          td React
          td.
            Declarative rendering, component-based development, and one-way data flow make React a
            superior alternative to direct DOM manipulation for moderately (or highly) complex
            client-side apps.
        tr
          td #[i.devicon-redis-plain-wordmark.colored]
          td Redis
          td.
            An amazingly fast in-memory database. My main exposure has been via the Sidekiq
            job-processing library, and simple set and get commands.
        tr
          td
            PerformantImage(alt='Elasticsearch' imageStyle='height: 65px' lazy=true)
              source(type='png' src='~img/rspec.png')
          td RSpec
          td.
            I #[em.italic love] testing. (I write more lines of spec code per line of application
            code than any other developer on the team at Hired.) RSpec makes tests readable and easy
            to write.
        tr
          td #[i.devicon-ruby-plain-wordmark.colored]
          td Ruby
          td Ruby prizes developer happiness, and it shows!
        tr
          td #[i.devicon-rails-plain-wordmark.colored]
          td Ruby on Rails

          td.
            I ❤️  &nbsp;Rails: a web-development framework with a great ecosystem that makes
            development fast and fun. Rails's ActiveRecord ORM is superb.
        tr
          td #[i.devicon-sass-plain.colored]
          td Sass
          td.
            It's in the name - syntactically awesome style sheets. Why write CSS when you can write
            Sass? :)
        tr
          td #[i.devicon-vuejs-plain-wordmark.colored]
          td VueJS
          td.
            I think that Vue is one of the best client-side frameworks/libraries out there, and I'm
            really hoping that its popularity continues to grow. I keep track of my grocery list
            using #[a(:href='$routes.groceries_path()') an app that I built with Vue].
        tr
          td #[i.devicon-webpack-plain-wordmark.colored]
          td Webpack
          td.
            A versatile and powerful build tool for all-things client-side.
            #[span.monospace webpack‑dev‑server] and hot code reloading really enhance the
            development experience.

  .parallax-outer
    .parallax-inner.parallax-inner--macbook-1

  HomeSection(section='projects', title='Projects')
    Project
      span(slot='title') My Grocery List
      span(slot='technologies') Rails 5, Vue.js, Vuex, Nexmo SMS API
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
          I choose not to own a smartphone (😱 ), and I eat the same few things week after week.
          With this in mind, I wanted an app that would help me to efficiently track and purchase
          groceries. Plus, I wanted an excuse to experiment with
          #[a(href='https://vuejs.org/') Vue.js]!. So I built
          #[a(:href='this.$routes.groceries_path()') davidrunger.com/groceries].
        p.
          I use this app to keep track of which grocery items I need. Then, when it's time to go
          shopping, I text the grocery list to myself via the Nexmo SMS API, so that I can easily to
          refer to it on my "dumb" phone while I'm at the store.
      ul(slot='tech-list')
        li.
          A #[b Rails 5] back end serves a #[b Vue.js] front end application that's built with
          #[b #[a(href='https://pugjs.org') pug]] templates, ES6 (via
          #[b #[a(href='https://babeljs.io/') babel]]), and
          #[b #[a(href='http://sass-lang.com/') Sass]].
        li.
          Rails 5's #[b webpacker] gem provides #[b Hot Module Replacement] for
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
          The official #[b #[a(href='https://github.com/vuejs/vue-test-utils') vue-test-utils]]
          library facilitates Vue component unit testing. Tests are run using #[b Mocha],
          #[b headless Chrome], and "regular" (non-headless) Chrome.
        li.
          #[b Continuous integration (CI)] via Travis, which also provides
          #[b continuous deployment (CD)] via #[b Heroku] (which hosts the app)
        li.
          Ruby code is linted by #[b RuboCop], JavaScript by #[b ESLint], and stylesheets by
          #[b Stylelint].

    Project
      span(slot='title') FastFeedback.io
      span(slot='technologies') Ruby on Rails, Backbone.js, Nexmo SMS API
      div(slot='links')
        a(href='http://www.fastfeedback.io') Live
        span #{' - '}
        a(href='http://github.com/davidrunger/fast_feedback') GitHub
      PerformantImage(slot='image' alt='FastFeedback.io' lazy=true)
        source(type='png' src='~img/fast_feedback.png')
        source(type='webp' src='~img/fast_feedback.webp')
      div(slot='overview')
        p.
          Do you need to engage your audience during a presentation? FastFeedback.io can help.
          Prepare some interesting questions ahead of time, and browse through them as you make your
          presentation. Your audience can cast votes using either a web interface or text messages.
          A chart displaying the results dynamically updates in real-time as the votes come in!
      ul(slot='tech-list')
        li Entirely single-page app
        li Rails back end serves a JSON API
        li Backbone.js on the front end
        li Integration with Nexmo API for text messages
        li Highcharts.js library provides dynamic, animated charts

    Project
      span(slot='title') Rosetta Code Languages Selector
      span(slot='technologies') Chrome Extension, Capybara integration tests
      div(slot='links')
        a(href='https://chrome.google.com/webstore/detail/rosetta-code-languages-se/icjinpkbplhheomciikehmieadoibljg') Live
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

    Project
      span(slot='title') App Academy Picture Flashcard App
      span(slot='technologies') jQuery, object-oriented JavaScript
      div(slot='links')
        a(href='https://davidrunger.github.io/aa-picture-game/') Live
        span #{' - '}
        a(href='https://github.com/davidrunger/aa-picture-game') GitHub
      PerformantImage(slot='image' alt='App Academy Picture Game' lazy=true)
        source(type='png' src='~img/aa-picture-game.png')
        source(type='webp' src='~img/aa-picture-game.webp')
      div(slot='overview')
        p.
          This is a simple little tool built with jQuery for App Academy that we would always use to
          help students and staff learn each other's names at the beginning of a new cohort. It's
          very effective!
      ul(slot='tech-list')
        li.
          An awesome loading spinner (built upon the work of
          #[a(href='http://codepen.io/ZevanRosser/pen/ilfHK') Zevan Rosser]).
        li Fuzzy string matching, so you get partial credit for a nearly-correct guess.

    Project
      span(slot='title') Serpent.js
      span(slot='technologies') jQuery, object-oriented JavaScript
      div(slot='links')
        a(href='https://davidrunger.github.io/serpent') Live
        span #{' - '}
        a(href='http://github.com/davidrunger/serpent') GitHub
      PerformantImage(slot='image' alt='Serpent Game' lazy=true)
        source(type='jpg' src='~img/serpent.jpg')
        source(type='webp' src='~img/serpent.webp')
      div(slot='overview')
        p.
          Serpent is twice as fun as classic Snake; at least, there are twice as many players. Each
          snake can easily be toggled between human or AI control, so you can play against the
          computer or a friend. Or just watch two AIs play each other. Or see whether your right or
          left hand is smarter. Controls allow for customizing the game speed and board dimensions.
      ul(slot='tech-list')
        li.
          Efficiently manipulates the DOM, allowing for large game boards and unreasonably high
          game speeds
        li.
          Trigonometry and <code>:before</code> pseudo-elements keep the snakes' pupils directed
          toward the apple at all times

    Project
      span(slot='title') Letter Flash Typing Practice
      span(slot='technologies') jQuery
      div(slot='links')
        a(href='https://davidrunger.github.io/letter-flash') Live
        span #{' - '}
        a(href='https://github.com/davidrunger/letter-flash') GitHub
      PerformantImage(slot='image' alt='Letter Flash Typing Practice' lazy=true)
        source(type='png' src='~img/letter-flash.png')
        source(type='webp' src='~img/letter-flash.webp')
      div(slot='overview')
        p.
          This is a simple tool that I built for myself when I was re-learning the QWERTY keyboard
          layout after years of typing with the Dvorak keyboard layout. I do think that it was
          helpful, and I continue to use it every once in a while.

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
import SmoothScroll from 'smooth-scroll/dist/js/smooth-scroll.min';
import PerformantImage from 'components/performant_image.vue';

import * as positionListener from './scripts/position_listener';
import HomeSection from './components/home_section.vue';
import Project from './components/project.vue';

export default {
  components: {
    HomeSection,
    PerformantImage,
    Project,
  },

  mounted() {
    positionListener.init();
    new SmoothScroll('a[href*="#"]');
  },

  props: {},
};
</script>

<style lang='scss' scoped>
@import '~css/variables';

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

i[class^=devicon-] {
  font-size: 65px;
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

      &:not(.active) span {
        border-bottom-color: rgba($white-dark, 0);
      }

      &.active span {
        border-bottom-color: rgba($white-dark, 0.8);
      }

      span {
        border-bottom-width: 2px;
        border-bottom-style: solid;
        transition: border-bottom-color 1s ease-out;
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

.skills table {
  tr:not(:first-child) {
    border-top: 1px solid $gray-lighter;
  }

  td {
    margin: 10px 0;
    padding: 0 10px;
    height: 75px;
    vertical-align: middle;
    line-height: 20px;
  }

  td:nth-child(2) {
    font-weight: bold;
    text-align: center;
  }
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
