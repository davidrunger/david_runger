<template lang='pug'>
HomeSection.pb4(
  section='resume'
  title='Resume'
)
  a.resume-button.block.center(href='/David-Runger-Resume.pdf') View Resume (pdf)
</template>

<script>
import HomeSection from './home_section.vue';

export default {
  components: {
    HomeSection,
  },
};
</script>

<style lang='scss'>
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
</style>
