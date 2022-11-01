<template lang='pug'>
HomeSection(section='contact', title='Contact me')
  p #[b Email:] #[a(href='mailto:davidjrunger@gmail.com') davidjrunger@gmail.com]
  p #[b LinkedIn:] #[a(href='https://linkedin.com/in/davidrunger') /in/davidrunger]
  p #[b GitHub:] #[a(href='https://github.com/davidrunger') @davidrunger]
</template>

<script>
import HomeSection from './home_section.vue';

export default {
  components: {
    HomeSection,
  },
};
</script>
