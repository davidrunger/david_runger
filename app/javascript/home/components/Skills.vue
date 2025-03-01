<template lang="pug">
HomeSection(section="skills", title="Skills")
  table
    tbody
      SkillRow(
        name="Cloudflare",
        details="A capable CDN and a vital layer of protection against DDoS attacks."
      )
      SkillRow(name="CSS3", details="Because looking good is half the battle!")
      SkillRow(
        name="Docker",
        details=`
          A powerful tool for deploying web applications reliably and quickly.
          (This site is deployed using Docker Compose.)
        `
      )
      SkillRow(
        name="Elasticsearch / OpenSearch",
        details="A fast, powerful, and flexible search backend."
      )
      SkillRow(name="Git", details="The standard in version control.")
      SkillRow(
        name="GitHub",
        details=`
          Where software teams and the open source community collaborate. GitHub Actions are
          great!
        `
      )
      SkillRow(
        name="Heroku",
        details="Doing (some of) the devops, so you don't have to."
      )
      SkillRow(name="HTML5", details="The building block of the Internet!")
      SkillRow(
        name="JavaScript",
        details=`
          A flexible language, essential for any modern web app. ES6 (plus lodash to fill in some
          utility functions) makes JavaScript coding pretty enjoyable.
        `
      )
      SkillRow(
        name="Jest",
        details="A fast and effective JavaScript unit testing library."
      )
      SkillRow(
        name="Jira",
        details=`
          A quality tool for organizing software teams. I like Jira so much that
          I use it to plan and track work on my personal projects!
        `
      )
      SkillRow(
        name="Lodash",
        details=`
          Lodash brings a lot of the conciseness, convenience, and clarity that
          I love about Ruby to the front end.
        `
      )
      SkillRow(
        name="NodeJS",
        details=`
          Node and its package managers and frontend libraries are essential
          parts of the modern web stack.
        `
      )
      SkillRow(
        name="PostgreSQL",
        details="A fast, rock-solid, open source, and richly featured SQL database."
      )
      SkillRow(
        name="React",
        details=`
          Declarative, reactive rendering and component-based development make
          React a superior alternative to direct DOM manipulation for
          client-side applications of more than trivial complexity.
        `
      )
      SkillRow(name="Redis", details="A fast, in-memory database.")
      SkillRow(
        name="RSpec",
        details="I love testing, and RSpec makes tests readable and easy to write."
      )
      SkillRow(
        name="Ruby",
        details="Ruby was designed for developer happiness, and it shows!"
      )
      SkillRow(
        name="Ruby on Rails",
        details=`
          A web-development framework with a great ecosystem that makes development fast and fun.
          Rails's ActiveRecord ORM is superb.
        `
      )
      SkillRow(
        name="Sass",
        details=`
          It's in the name - syntactically awesome style sheets. Why write CSS, when you can write
          Sass?
        `
      )
      SkillRow(
        name="Tailwind CSS",
        details="A utility-first CSS framework that makes styling quick and easy."
      )
      SkillRow(
        name="TypeScript",
        details=`
          The guarantees provided by types reduce the likelihood of bugs and
          enable tooling that can make the development process relatively
          efficient and even enjoyable compared to more dynamic languages.
        `
      )
      SkillRow(
        name="VueJS",
        details=`
          A great framework for building front-end UX with a great supporting
          ecosystem. I hope that its popularity continues to grow.
        `
      )
</template>

<script setup lang="ts">
import HomeSection from './HomeSection.vue';
import SkillRow from './SkillRow.vue';
</script>
