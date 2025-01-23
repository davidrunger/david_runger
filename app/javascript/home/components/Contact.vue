<template lang="pug">
HomeSection(section='links', title='Contact me / Links')
  p #[b Email:] #[a(href='mailto:davidjrunger@gmail.com') davidjrunger@gmail.com]
  p #[b LinkedIn:] #[a(href='https://www.linkedin.com/in/davidrunger/') /in/davidrunger]
  p #[b GitHub:] #[a(href='https://github.com/davidrunger') @davidrunger]
  p #[b Blog:] #[a(href='/blog') my tech blog]
</template>

<script setup lang="ts">
import HomeSection from './HomeSection.vue';
</script>
