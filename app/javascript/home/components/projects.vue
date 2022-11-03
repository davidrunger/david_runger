<template lang='pug'>
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
          #[a(href='https://davidrunger.com/groceries') Groceries]* -
          the collaborative family grocery list, built to be mobile-friendly for use on-the-go

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

      p *#[strong Google login required]

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
          #[a(href='https://sass-lang.com/') Sass].

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

          A custom-built, #[a(href='https://github.com/linkyndy/pallets') pallets]-based,
          parallelized test runner workflow executes only the tests and other checks that are
          needed for any given PR, making development and deployment as fast as possible while
          ensuring application stability.

        li.

          A custom-built, #[a(href='https://github.com/rubycdp/ferrum') ferrum]-based prerendering
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

          #[a(href='https://basscss.com/') Basscss] provides CSS utility classes, so a
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
        a(href='https://github.com/davidrunger/serpent') GitHub
    template(v-slot:image)
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

</template>

<script>
import HomeSection from './home_section.vue';
import Project from './project.vue';

export default {
  components: {
    HomeSection,
    Project,
  },
};
</script>

<style>
.project-container:last-of-type {
  margin-bottom: var(--space-3);
}
</style>
