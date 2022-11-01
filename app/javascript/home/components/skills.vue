<template lang='pug'>
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
</template>

<script>
import HomeSection from './home_section.vue';
import SkillRow from './skill_row.vue';

export default {
  components: {
    HomeSection,
    SkillRow,
  },
};
</script>
