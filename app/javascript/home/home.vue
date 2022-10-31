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
          LoadNotifyingImage.center.mt1.mb3
            img.about-image.box-shadow(
              src='~img/david.webp'
              alt='A picture of me'
            )

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
            LoadNotifyingImage
              img(
                src='~img/rspec.webp'
                alt='RSpec'
              )
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
        a(href='https://github.com/davidrunger/david_runger/') GitHub
      template(v-slot:overview)
        p.

          You are here, at #[a(href='https://davidrunger.com') davidrunger.com]! This is a
          playground for me to experiment with various web technologies, and where I host various
          apps that I have built for myself and my family:

        ul

          li.
            #[a(href='https://davidrunger.com/groceries') Groceries]#[span.bold *] -
            the collaborative family grocery list, built to be mobile-friendly for use on-the-go

          li.
            #[a(href='https://davidrunger.com/workout') Workout]#[span.bold *] -
            an app for tracking workouts over time, and to stay on-pace within a workout

          li.
            #[a(href='https://davidrunger.com/logs') Logs]#[span.bold *] -
            track whatever you want with various log types (text, number, duration, and/or counter)

          li.
            #[a(href='https://davidrunger.com/quizzes') Quizzes]#[span.bold *] -
            a multi-person quiz app that uses ActionCable websockets for real-time interactivity

          li.
            #[a(href='https://davidrunger.com/check_ins') Check-ins]#[span.bold *] -
            track how well your emotional needs are being met in your marriage/relationship

        p #[span.bold *]#[strong Google login required]

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

            The app's 2,500+ lines of Ruby code are
            #[a(href='https://app.codecov.io/gh/davidrunger/david_runger/tree/master') #[span.bold 100%] covered by tests]
            written with #[a(href='https://rspec.info/') RSpec].

          li.

            The primary database is
            #[a(href='https://www.postgresql.org/') PostgreSQL],
            plus some use of
            #[a(href='https://redis.io/') Redis], and
            #[a(href='https://memcached.org/') Memcached] for cacheing.

          li.
            #[a(href='https://pinia.vuejs.org/') Pinia] provides client-side state management.

          li.

            The excellent
            #[a(href='https://vite-ruby.netlify.app/guide/rails.html') Vite Rails]

            gem, in conjunction with Vue and Pinia, provides sub-second hot module replacement (HMR)
            in development, creating an efficient and enjoyable workflow. Vite Rails also bundles
            the application's JavaScript and CSS for production. (I believe that Vite Rails is an
            underappreciated gem, and the premier solution for JavaScript management in the Rails
            ecosystem at this time, better than any of the options

            #[a(href='https://github.com/rails/webpacker#readme') mentioned here].

            Hats off to the developer,

            #[a(href='https://maximomussini.com/posts/a-rubyist-guide-to-vite-js') Máximo Mussini]!)

          li.

            #[a(href='https://developers.google.com/identity/protocols/oauth2') Google OAuth]
            provides convenient and secure sign-in.

          li.

            #[a(href='https://github.com/features/actions') GitHub Actions] provides continuous
            integration (CI) testing and linting, as well as
            continuous deployment (CD) via integration with
            #[a(href='https://dokku.com/') Dokku] on a
            #[a(href='https://www.digitalocean.com/') DigitalOcean] host.

          li.

            A custom-built #[a(href='https://github.com/linkyndy/pallets') pallets]-based,
            parallelized test runner workflow executes only the tests and other checks that are
            needed for any given PR, making development and deployment as fast as possible while
            ensuring application stability.

          li.

            A custom-built #[a(href='https://github.com/rubycdp/ferrum') ferrum]-based prerendering
            system captures and then serves a static HTML version of the JavaScript-based homepage,
            allowing me to enjoy the developer-friendly ergonomics of a Vue-based workflow in
            development, while still serving a simple HTML page in production for optimal rendering
            performance and search engine optimization.

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

          li.

            #[a(href='http://basscss.com/') Basscss] provides CSS utility classes, so a
            lot of styling can be done quickly and cleanly within the markup itself.

          li.

            #[a(href='https://github.com/railsware/js-routes') JsRoutes] allows the
            use of Rails named routes / path helpers on the client-side, too! :)

          li.

            #[a(href='https://element-plus.org/#/en-US') Element Plus] provides aesthetic and
            ready-to-use Vue UI components.

          li.

            Plus...
              #[a(href='https://router.vuejs.org/') Vue Router] client-side routing,
              #[a(href='https://github.com/mperham/sidekiq') Sidekiq] background jobs,
              #[a(href='https://github.com/jnunemaker/flipper') Flipper] feature flags,
              #[a(href='https://github.com/heartcombo/devise') Devise] authentication,
              #[a(href='https://activeadmin.info/') Active Admin] admin backend,
              #[a(href='https://github.com/drapergem/draper') Draper] decorators,
              #[a(href='https://github.com/varvet/pundit') Pundit] authorization,
              #[a(href='https://github.com/rails-api/active_model_serializers') active_model_serializers] model-to-JSON serialization,
              #[a(href='https://guides.rubyonrails.org/action_mailer_basics.html') Action Mailer] outbound emails,
              #[a(href='https://guides.rubyonrails.org/action_mailbox_basics.html') Action Mailbox] inbound emails,
              #[a(href='https://guides.rubyonrails.org/security.html#custom-credentials') Rails encrypted credentials],
              #[a(href='https://github.com/davidrunger/active_actions') active_actions] form objects / command objects,
              #[a(href='https://github.com/davidrunger/skedjewel') Skedjewel] Sidekiq job scheduling,
              #[a(href='https://github.com/paper-trail-gem/paper_trail') PaperTrail] model change tracking,
              #[a(href='https://github.com/rack/rack-attack') Rack::Attack] IP blocking and request throttling,
              #[a(href='https://github.com/flyerhzm/bullet') Bullet] eager-loading enforcement,
              #[a(href='https://github.com/evilmartians/lefthook') Lefthook] git hook management,
              #[a(href='https://github.com/zricethezav/gitleaks') Gitleaks] secret protection,
              #[a(href='https://aws.amazon.com/s3/') AWS S3] blob storage,
              #[a(href='https://rollbar.com/') Rollbar] error tracking,
              and #[a(href='https://percy.io/David-Runger/david_runger') Percy] visual diff monitoring!

    Project
      template(v-slot:title)
        span Serpent.js
      template(v-slot:technologies)
        span jQuery, object-oriented JavaScript
      template(v-slot:links)
        div
          a(href='https://davidrunger.github.io/serpent') Live
          span {{' - '}}
          a(href='http://github.com/davidrunger/serpent') GitHub
      template(v-slot:image)
        LoadNotifyingImage
          img.box-shadow(
            src='~img/serpent.webp'
            alt='Serpent Game'
          )
      template(v-slot:overview)
        div(slot='overview')
          p.
            Serpent is twice as fun as classic Snake. At least, there are twice as many players!
            Each snake can be toggled between human or AI control, so you can play against the
            computer or a friend. Or just watch two AIs play each other. Or see whether your right
            or left hand is smarter. Controls allow for customizing the game speed and board
            dimensions.
      template(v-slot:tech-list)
        ul
          li.
            Efficiently manipulates the DOM, allowing for large game boards and unreasonably high
            game speeds
          li.
            Trigonometry and <code>:before</code> pseudo-elements keep the snakes' pupils directed
            toward the apple at all times

    Project(
      image-container-class='mb0'
      links-container-class='mb0'
    )
      template(v-slot:title)
        span SimpleCov::Formatter::Terminal
      template(v-slot:technologies)
        span Ruby
      template(v-slot:links)
        div
          a(href='https://github.com/davidrunger/simple_cov-formatter-terminal') GitHub
      template(v-slot:image)
        LoadNotifyingImage
          img(
            src='~img/simplecov-terminal.webp'
            alt='SimpleCov::Formatter::Terminal'
          )
      template(v-slot:overview)
        div(slot='overview')
          p.
            Having good test coverage is important to me. It lowers the chance of shipping bugs and
            makes it possible to update dependencies with confidence and without manual testing.

          p.
            However, I couldn't find a way to get quick, detailed feedback about my app's code
            coverage while working on tests &mdash; so I wrote
            #[code SimpleCov::Formatter::Terminal].
            It prints line-by-line code coverage information to the
            terminal after every test run, and includes info about branch coverage, as well, making
            it easy to see where test coverage is missing, and to add tests covering the uncovered
            code.

          p
            | Thanks to dog-fooding #[code SimpleCov::Formatter::Terminal] on itself, I'm easily
            | able to keep its {{' '}}
            a(href='https://app.codecov.io/gh/davidrunger/simple_cov-formatter-terminal/tree/master')
              | code coverage at 100%
            | .

    Project
      template(v-slot:title)
        span Skedjewel
      template(v-slot:technologies)
        span Crystal
      template(v-slot:links)
        div
          a(href='https://github.com/davidrunger/skedjewel') GitHub
      template(v-slot:image)
        LoadNotifyingImage
          img.box-shadow(
            src='~img/skedjewel.webp'
            alt='skedjewel.yml'
          )
      template(v-slot:overview)
        div(slot='overview')
          p.

            DavidRunger.com has some Sidekiq jobs that I want to run at various scheduled intervals.
            There are some gems to help with this, like
            #[a(href='https://github.com/sidekiq-scheduler/sidekiq-scheduler/') sidekiq-scheduler],
            but, at the time of writing, it
            #[a(href='https://github.com/sidekiq-scheduler/sidekiq-scheduler/issues/409') doesn't work with Sidekiq 7].

          p.

            Thus, partially as an excuse to try out the
            #[a(href='https://crystal-lang.org/') Crystal]

            programming language, I wrote a simple job runner in Crystal called
            #[code skedjewel],

            which I use to execute scheduled Sidekiq jobs for DavidRunger.com. I love the small
            memory consumption of the compiled skedjewel Crystal binary, since memory is a precious
            resource on my small DigitalOcean droplet.

    Project
      template(v-slot:title)
        span Assorted Gems
      template(v-slot:technologies)
        span Ruby
      template(v-slot:overview)
        div(slot='overview')
          p.

            Below are some of the Ruby gems that I've written.

          ul
            li.

              #[a(href='https://github.com/davidrunger/active_actions') #[code active_actions]]:

              The missing piece of Rails! Organize and validate the actions of your Rails
              application with this combined form object / command object.

            li.

              #[a(href='https://github.com/davidrunger/shaped') #[code shaped]]:

              Validate the shape of Ruby objects (hashes, arrays, and more). This is a dependency
              used in #[code active_actions] (mentioned just above).

            li.

              #[a(href='https://github.com/davidrunger/fcom') #[code fcom]]:

              A CLI tool for parsing git history. I use this regularly.

            li.

              #[a(href='https://github.com/davidrunger/rspec_performance_summary') #[code rspec_performance_summary]]:

              Find low-hanging / high-impact opportunities to speed up your test suite by printing
              the execution time of your slowest RSpec examples.

            li.

              #[a(href='https://github.com/davidrunger/schedjewel') #[code schedjewel]]:

              Execute Sidekiq jobs on a schedule. (This is essentially a Ruby version of the Crystal
              #[code skedjewel] project mentioned above.)

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
import LoadNotifyingImage from '@/components/load_notifying_image.vue';
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
    LoadNotifyingImage,
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

:deep(.project-container:last-of-type) {
  margin-bottom: var(--space-3);
}
</style>
