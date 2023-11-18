<template lang='pug'>
HomeSection(section='about', title='About me', :renderHeadingManually='true')
  template(v-slot:default='slotProps')
    .sm-flex.row-reverse.items-center
      .flex-2.mt1
        .center.mt1.mb3
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

          I'm a support engineer at #[a(href='https://www.commonlit.org/') CommonLit]. In the past,
          I've been a software engineer and support engineer at
          #[a(href='https://hired.com') Hired], a web development boot camp teaching assistant at
          #[a(href='https://www.appacademy.io/') App&nbsp;Academy], a high school math teacher, a
          public bus driver, and a long haul truck driver.
</template>

<script lang='ts'>
import HomeSection, { SectionHeader } from './home_section.vue';

export default {
  components: {
    HomeSection,
    SectionHeader,
  },
};
</script>

<style>
@media (width >= 40em) {
  .sm-flex {
    display: flex;
  }

  .sm-px4 {
    padding-left: var(--space-4);
    padding-right: var(--space-4);
  }
}

.about-image {
  max-width: 100%;
}
</style>
