<template lang='pug'>
div
  #home.flex.flex-column.relative.vh-100.align-items-center.justify-content-space-around.background-black.font-white-dark.p-5
    .spacer.flex-grow-1
    //- HACK: add `data-section=''` so that we will clear the selected nav element when scrolled to
    //- the top of the page
    #headline-container.flex-grow-1(data-section='')
      #headline-name.monospace.font-size-1.font-blue-light.pb-5.mb-5.border-b-1.border-gray-dark.pb-2
        span David Runger
      #headline-subtitle.font-size-3.light Full stack web developer
    header#header.fixed-top.flex-grow-1.flex.background-black.width-100.relative
      #header-name.font-size-4.js-link.js-scroll-top.m-l-3
        a.monospace.font-blue-light(href='#home') David Runger
      nav#nav.flex.justify-content-space-around.absolute.m-r-4
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
      .about-me.flex-2.background--translucent-white.m-r-5.p-3
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

      .pr-6.text-center.flex-1.flex.align-items-center
        img.about-image(src='~img/david.jpg' alt='A picture of me')

  HomeSection(section='skills', title='Skills / Technologies', color-palette='Purples')
    table
      tbody
        tr
          td #[i.devicon-babel-plain.colored]
          td Babel
          td For all that sweet, sweet ES6 syntax.
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
          td #[img(src='~img/rspec.png' alt='Elasticsearch' style='height: 65px')]
          td RSpec
          td.
            I #[i love] testing. (I write more lines of spec code per line of application code than
            any other developer on the team at Hired.) RSpec makes tests readable and easy to write.
        tr
          td #[i.devicon-ruby-plain-wordmark.colored]
          td Ruby
          td Ruby prizes developer happiness, and it shows!
        tr
          td #[i.devicon-rails-plain-wordmark.colored]
          td Ruby on Rails

          td.
            I ❤️  Rails. A web-development framework with a great ecosystem that makes development
            fast and fun. ActiveRecord is a superb ORM.
        tr
          td #[i.devicon-sass-plain.colored]
          td Sass
          td.
            It's in the name - syntactically awesome style sheets. Why write CSS when you could
            write SASS? :)
        tr
          td #[i.devicon-vuejs-plain-wordmark.colored]
          td VueJS
          td.
            I think that Vue is one of the best client-side frameworks/libraries out there, and I'm
            really hoping that its popularity continues to grow. I keep track of my grocery list
            using #[a(href='/groceries') an app that I built with Vue].
        tr
          td #[i.devicon-webpack-plain-wordmark.colored]
          td Webpack
          td.
            A versatile and powerful build tool for all-things client-side.
            #[span.monospace webpack‑dev‑server] and hot code reloading really enhance the
            development experience.

  HomeSection(section='projects', title='Projects', color-palette='Blues')
    p
      article.project.content
        h3.title FastFeedback.io
        h4.technologies Ruby on Rails, Backbone.js
        h4.subtitle
          a(href='http://www.fastfeedback.io') Live
          span #{' - '}
          a(href='http://github.com/davidrunger/fast_feedback') GitHub

        img(src='~img/fast_feedback.png' alt='FastFeedback.io')

        p.

          Do you need to engage your audience during a presentation? FastFeedback.io can help.
          Prepare some interesting questions ahead of time, and browse through them as you make your
          presentation. Your audience can cast votes using either a web interface or text messages.
          A chart displaying the results dynamically updates in real-time as the votes come in!

        h3 Features
        ul.features
          li Entirely single-page app
          li Rails back end serves a JSON API
          li Backbone.js on the front end
          li Integration with Nexmo API for text messages
          li Highcharts.js library provides dynamic, animated charts

      article.project.content
        h3.title Rosetta Code Languages Selector
        h4.technologies Chrome Extension, Capybara integration tests
        h4.subtitle
          a(href='https://chrome.google.com/webstore/detail/rosetta-code-languages-se/icjinpkbplhheomciikehmieadoibljg') Live
          span #{' - '}
          a(href='https://github.com/davidrunger/rc-languages-selector') GitHub

        img(src='~img/rc-languages-selector.png' alt='Rosetta Code Languages Selector')

        p.
          #[a(href='http://rosettacode.org/wiki/Rosetta_Code') RosettaCode.org] is a great website
          for comparing programming languages and/or learning a new language based on others that
          you already know. However, for each sample programming task, there are so many
          implementations available in different languages that it can be difficult to find the code
          samples for the languages that you are focusing on. This extension solves that problem by
          only showing code samples for languages that you have specifically selected.


        h3 Features
        ul.features
          li.
            Comprehensive Capybara integration test suite allows for confident refactoring and
            feature extension.
          li.
            Custom testing solution mimics the Chrome Extension API by monkeypatching the Capybara
            library to automatically inject the extension's JavaScript and CSS assets into any page
            visited during an integration test.

      article.project.content
        h3.title App Academy Picture Flashcard App
        h4.technologies jQuery, object-oriented JavaScript
        h4.subtitle
          a(href='https://davidrunger.github.io/aa-picture-game/') Live
          span #{' - '}
          a(href='https://github.com/davidrunger/aa-picture-game') GitHub

        img(src='~img/aa-picture-game.png' alt='App Academy Picture Game')

        p.
          This is a simple little tool built with jQuery for App Academy that we would always use to
          help students and staff learn each other's names at the beginning of a new cohort. It's
          very effective!

        h3 Features
        ul.features

          li.
            An awesome loading spinner (built upon the work of
            #[a(href='http://codepen.io/ZevanRosser/pen/ilfHK') Zevan Rosser]).
          li Fuzzy string matching, so you get partial credit for a nearly-correct guess.

      article.project.content
        h3.title Serpent.js
        h4.technologies jQuery, Object-Oriented JavaScript
        h4.subtitle
          a(href='https://davidrunger.github.io/serpent') Live
          span #{' - '}
          a(href='http://github.com/davidrunger/serpent') GitHub

        img(src='~img/serpent.jpg' alt='Serpent Game')

        p.
          Serpent is twice as fun as classic Snake; at least, there are twice as many players. Each
          snake can easily be toggled between human or AI control, so you can play against the
          computer or a friend. Or just watch two AIs play each other. Or see whether your right or
          left hand is smarter. Controls allow for customizing the game speed and board dimensions.

        h3 Features
        ul.features
          li.
            Efficiently manipulates the DOM, allowing for large game boards and unreasonably high
            game speeds
          li.
            Trigonometry and <code>:before</code> pseudo-elements keep the snakes' pupils directed
            toward the apple at all times

      article.project.content
        h3.title Letter Flash Typing Practice
        h4.technologies jQuery
        h4.subtitle
          a(href='https://davidrunger.github.io/letter-flash') Live
          span #{' - '}
          a(href='https://github.com/davidrunger/letter-flash') GitHub

        img(src='~img/letter-flash.png' alt='Letter Flash Typing Practice')

        p.
          This is a simple tool that I built for myself when I was re-learning the QWERTY keyboard
          layout after years of typing on Dvorak. I do think that it was helpful, and I continue to
          use it every once in a while.

  HomeSection(section='resume', title='Resume', color-palette='PuRd')
    p
      a.resume-button(href='/David-Runger-Resume.pdf') Download Resume (pdf)

  HomeSection(section='contact', title='Contact me', color-palette='GnBu')
    table.pure-table
      tbody
        tr.pure-table-odd
          td Email
          td.center #[a(href='mailto:davidjrunger@gmail.com') davidjrunger@gmail.com]

        tr
          td LinkedIn
          td.center #[a(href='https://linkedin.com/in/davidrunger') /in/davidrunger]

        tr.pure-table-odd
          td GitHub
          td.center #[a(href='https://github.com/davidrunger') @davidrunger]

        tr
          td Anonymous Feedback
          td.center
            a(href='https://docs.google.com/forms/d/1owogS54t2SBpZDtpS_A0QF6Fw-khaJOtdX6EN8EQd_k/viewform').
              via Google Forms
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
    new SmoothScroll('a[href*="#"]');
  },
};
</script>

<style lang='scss' scoped>
@import '~css/variables';

i[class^=devicon-] {
  font-size: 65px;
}

#header {
  position: fixed;
  height: 56px;
  top: 0;
  line-height: 56px;
  z-index: 1;

  #header-name {
    opacity: 0;
  }

  #header-name {
    opacity: 1;
    animation: delayed-fade-in $transition-medium;
  }

  #nav {
    width: 500px;
    right: 0;
    transform: translateX(0);

    a.nav-link {
      color: $gray-light;

      &.active {
        color: $white-dark;
      }

      &:hover {
        color: white;
      }
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

  @media screen and (max-width: 600px) {
    display: none;
  }
}

.nav-link {
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

.about-image {
  max-width: 100%;
  box-shadow: $gray-light 0 2px 5px;
}

.background--translucent-white {
  background: rgba(255, 255, 255, 0.9);
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
  box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.3);
  margin-bottom: 30px; // needs to be big enough to psh above header when clicking 1st section
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
  display: block;
  width: 240px;
  height: 60px;
  line-height: 56px;
  text-align: center;
  background-color: rgba(0, 0, 0, 0.72);
  border: 2px solid #000;
  border-radius: 3px;
  box-shadow: #000 0 0 15px -3px;
  color: gainsboro;

  &:hover {
    background-color: rgba(20, 20, 20, 0.72);
    transition: 0.3s;
  }
}

.contact {
  table {
    empty-cells: show;
    border: 1px solid #cbcbcb;
    border-collapse: collapse;
    border-spacing: 0;
    background-color: rgba(255, 255, 255, 0.6);
  }

  .pure-table-odd td,
  tr:nth-child(2n-1) td {
    background-color: #f2f2f2;
  }

  .pure-table td {
    background-color: white;
  }

  .pure-table td,
  .pure-table th {
    border-left: 1px solid #cbcbcb;
    border-width: 0 0 0 1px;
    font-size: inherit;
    margin: 0;
    overflow: visible;
    padding: 0.5em 1em;
  }
}

.projects {
  p {
    margin: 25px 50px 15px;
  }

  ul {
    margin: 10px 70px 20px;
  }

  li,
  p {
    line-height: 20px;
  }

  ul {
    list-style: initial;
  }

  img {
    border: 5px solid #484848;
    box-shadow: grey 0 0 13px 0;
    border-radius: 3px;
    max-height: 300px;
    max-width: 90%;
    display: block;
    margin: 8px auto 0;
  }

  .technologies {
    margin: 0 auto;
    color: #737373;
    font-weight: 500;
    font-size: 16px;
    line-height: 24px;
  }

  h3,
  h4 {
    text-align: center;
  }

  h3 {
    font-size: 32px;
  }

  .content {
    background: rgba(240, 240, 240, 0.75);
    padding: 20px;
    box-shadow: rgba(101, 121, 128, 0.51) 2px 2px 2px;
    margin-bottom: 30px;
  }

  .title {
    margin: 5px auto 0;
  }
}
</style>
