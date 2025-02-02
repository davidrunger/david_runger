<template lang="pug">
HomeSection(section='projects' title='Projects')
  Project.mt8
    template(v-slot:title)
      span DavidRunger.com
    template(v-slot:technologies)
      span Rails 8, Vue 3
    template(v-slot:links)
      a(href='https://github.com/davidrunger/david_runger/') GitHub
    template(v-slot:overview)
      p.

        Welcome to #[a(href='https://davidrunger.com') davidrunger.com] — my
        digital playground for experimenting with modern web technologies, where
        I host apps designed for everyday use by my family and me:

      ul

        li.
          #[a(:href='routes.emoji_picker_path()') Emoji Picker] -
          I couldn't find an emoji picker that met my needs (simple, fast,
          keyboard-first, and with the ability to customize emoji search
          keywords), so I
          #[a(href='https://github.com/davidrunger/david_runger/blob/main/app/javascript/emoji_picker/EmojiPicker.vue') built my own].

        li.
          #[a(:href='routes.groceries_path()') Groceries]* -
          Simplify and streamline your family's grocery shopping with a
          collaborative, mobile-friendly, real-time (WebSockets-enabled) list.

        li.
          #[a(:href='routes.workout_path()') Workout]* -
          An app for tracking workouts over time, and to stay on-pace within a workout.

        li.
          #[a(:href='routes.logs_path()') Logs]* -
          Track whatever you want with various log types (text, number, duration, and/or counter).

        li.
          #[a(:href='routes.quizzes_path()') Quizzes]* -
          A multi-person quiz app that uses ActionCable websockets for real-time interactivity.

        li.
          #[a(:href='routes.check_ins_path()') Check-ins]* -
          Track how well your emotional needs are being met in your marriage/relationship.

      p #[i *Google login required]

    template(v-slot:tech-list)
      ul
        li.
          A #[a(href='https://rubyonrails.org/') Rails 8] backend serves various
          #[a(href='https://vuejs.org/') Vue 3] front-end apps.

        li.

          The app's deployment is managed with
          #[a(href='https://docs.docker.com/compose/') Docker Compose] on a
          #[a(href='https://www.digitalocean.com/') DigitalOcean] host.

        li.

          The app's 6,000+ lines of testable Ruby code are
          #[a(href='https://app.codecov.io/gh/davidrunger/david_runger/tree/main') #[span.font-bold 100%] covered by tests]
          written with #[a(href='https://rspec.info/') RSpec].

        li.

          The excellent

          #[a(href='https://vite-ruby.netlify.app/guide/rails.html') Vite Rails]

          gem provides sub-second hot module replacement (HMR) in development,
          and compiles the application's TypeScript and CSS for production.

        li.

          The primary database is #[a(href='https://www.postgresql.org/') PostgreSQL],
          plus #[a(href='https://redis.io/') Redis] for Sidekiq, caching, and
          some direct use by the app.

        li.

          #[a(href='https://github.com/sidekiq/sidekiq') Sidekiq] processes background jobs.

        li.

          #[a(href='https://nginx.org/') NGINX] exposes the server to the web.

        li.
          #[a(href='https://pinia.vuejs.org/') Pinia] provides client-side state management.

        li.

          #[a(href='https://developers.google.com/identity/protocols/oauth2') Google OAuth]
          provides convenient and secure sign-in.

        li.

          #[a(href='https://github.com/features/actions') GitHub Actions] provides continuous
          integration (CI) testing and linting and continuous deployment (CD).

        li.

          Observability is provided by
          #[a(href='https://grafana.com/') Grafana] log search and metrics viewing,
          #[a(href='https://prometheus.io/') Prometheus] metrics collection and storage,
          #[a(href='https://github.com/grafana/loki') Loki] log storage,
          #[a(href='https://vector.dev/') Vector] log transformation and routing,
          #[a(href='https://github.com/google/cadvisor') cAdvisor] container monitoring,
          #[a(href='https://github.com/prometheus/node_exporter') Node exporter] system resource monitoring,
          and #[a(href='https://github.com/discourse/prometheus_exporter') prometheus_exporter] to provide Rails metrics for Prometheus.

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

          #[a(href='https://tailwindcss.com/') Tailwind] provides CSS utility classes, so a
          lot of styling can be done within the markup itself.

        li.

          #[a(href='https://github.com/railsware/js-routes') JsRoutes] allows the
          use of Rails named routes / path helpers on the client-side, too!

        li.

          #[a(href='https://element-plus.org/#/en-US') Element Plus] provides aesthetic and
          ready-to-use Vue UI components.

        li.

          A custom-built,

          #[a(href='https://github.com/linkyndy/pallets') pallets]-based,

          parallelized test runner determines and executes the subset of tests
          and other checks that are needed for any given PR, making development
          and deployment as fast as possible, while ensuring application
          stability.

        li.

          A custom-built, #[a(href='https://github.com/rubycdp/ferrum') ferrum]-based prerendering
          system captures and then serves a static HTML version of the JavaScript-based homepage,
          allowing me to enjoy the developer-friendly ergonomics of a Vue-based workflow in
          development, while still serving a simple HTML page in production for optimal rendering
          performance and search engine optimization (SEO).

        li.

          Plus...
            #[a(href='https://router.vuejs.org/') Vue Router] client-side routing,
            #[a(href='https://github.com/flippercloud/flipper') Flipper] feature flags,
            #[a(href='https://github.com/heartcombo/devise') Devise] authentication,
            #[a(href='https://activeadmin.info/') Active Admin] admin backend,
            #[a(href='https://github.com/drapergem/draper') Draper] decorators,
            #[a(href='https://github.com/varvet/pundit') Pundit] authorization,
            #[a(href='https://github.com/okuramasafumi/alba') alba] model-to-JSON serialization,
            #[a(href='https://guides.rubyonrails.org/action_mailer_basics.html') Action Mailer] outbound emails,
            #[a(href='https://guides.rubyonrails.org/action_mailbox_basics.html') Action Mailbox] inbound emails,
            #[a(href='https://guides.rubyonrails.org/action_cable_overview.html') Action Cable] websockets,
            #[a(href='https://github.com/davidrunger/runger_actions') runger_actions] form objects / command objects,
            #[a(href='https://github.com/davidrunger/skedjewel') Skedjewel] Sidekiq job scheduling,
            #[a(href='https://github.com/paper-trail-gem/paper_trail') PaperTrail] model change tracking,
            #[a(href='https://github.com/rack/rack-attack') Rack::Attack] IP blocking and request throttling,
            #[a(href='https://github.com/flyerhzm/bullet') Bullet] eager-loading enforcement,
            #[a(href='https://github.com/gitleaks/gitleaks') Gitleaks] secret protection,
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
        a(href='https://davidrunger.github.io/serpent/') Live
        span {{' - '}}
        a(href='https://github.com/davidrunger/serpent') GitHub
    template(v-slot:image)
      img.box-shadow(
        loading='lazy'
        src='~img/serpent.webp'
        alt='Serpent Game'
        width='239'
        height='300'
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
    image-container-class='mb-0'
    links-container-class='mb-0'
  )
    template(v-slot:title)
      span SimpleCov::Formatter::Terminal
    template(v-slot:technologies)
      span Ruby
    template(v-slot:links)
      div
        a(href='https://github.com/davidrunger/simple_cov-formatter-terminal') GitHub
    template(v-slot:image)
      img(
        loading='lazy'
        src='~img/simplecov-terminal.webp'
        alt='SimpleCov::Formatter::Terminal'
        width='640'
        height='386'
      )
    template(v-slot:overview)
      div(slot='overview')
        p.
          Having good test coverage is important to me. It lowers the chance of shipping bugs and
          makes it possible to update dependencies with confidence and without manual testing.

        p.
          However, I couldn't find a way to get quick, detailed feedback about my app's code
          coverage while working on tests &ndash; so I wrote
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
      img.box-shadow(
        loading='lazy'
        src='~img/skedjewel.webp'
        alt='skedjewel.yml'
        width='583'
        height='208'
      )
    template(v-slot:overview)
      div(slot='overview')
        p.

          DavidRunger.com has some Sidekiq jobs that I want to run at various scheduled intervals.
          There are some great add-on gems that provide this functionality, like
          #[a(href='https://github.com/sidekiq-scheduler/sidekiq-scheduler/') sidekiq-scheduler],
          but I wanted something that wasn't so dependent on Sidekiq internals.

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

            #[a(href='https://github.com/davidrunger/runger_actions') #[code runger_actions]]:

            The missing piece of Rails! Organize and validate the actions of your Rails
            application with this combined form object / command object.

          li.

            #[a(href='https://github.com/davidrunger/shaped') #[code shaped]]:

            Validate the shape of Ruby objects (hashes, arrays, and more). This is a dependency
            used in #[code runger_actions] (mentioned just above).

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

</template>

<script setup lang="ts">
import { routes } from '@/lib/routes';

import HomeSection from './HomeSection.vue';
import Project from './Project.vue';
</script>

<style>
.project-container:last-of-type {
  margin-bottom: var(--space-3);
}
</style>
