<template lang="pug">
HomeSection(
  section="about"
  title="About me"
  :renderHeadingManually="true"
)
  template(v-slot:default="slotProps")
    .row-reverse.items-center(class="sm:flex")
      .flex-2.mt-4
        .text-center.mt-4.mb-8
          img.about-image.box-shadow(
            loading="lazy"
            src="~img/david.webp"
            alt="A picture of me"
            width="235"
            height="353"
          )

      .flex-3.p-4(class="sm:px-16")
        SectionHeader(:title="slotProps.title")

        p I'm a full stack web developer.

        p.
          I love the Ruby programming language, the Rails web development framework, and the RSpec
          testing library. These are well-designed tools with strong supporting ecosystems that
          allow me to work efficiently and to have fun doing it.

        p.
          I have been a support engineer at #[a(href="https://www.commonlit.org/") CommonLit],
          a software engineer and support engineer at Hired
          (now part of #[a(href="https://www.lhh.com/us/en/hired/") LHH]),
          a web development boot camp teaching assistant at
          #[a(href="https://www.appacademy.io/") App&nbsp;Academy], a high school math teacher, a
          public bus driver, and a long haul truck driver.
</template>

<script setup lang="ts">
import HomeSection from './HomeSection.vue';
import SectionHeader from './SectionHeader.vue';
</script>

<style>
.about-image {
  max-width: 100%;
}
</style>
