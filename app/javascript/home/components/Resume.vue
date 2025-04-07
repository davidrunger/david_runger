<template lang="pug">
HomeSection.pb-16(
  section="resume"
  title="Resume"
)
  a.resume-button.block.text-center(
    href="https://david-runger-public-uploads.s3.amazonaws.com/David-Runger-Resume.pdf"
  ) View Resume (pdf)
</template>

<script setup lang="ts">
import HomeSection from './HomeSection.vue';
</script>

<style lang="scss">
.resume-button.resume-button {
  width: 240px;
  height: 60px;
  line-height: 56px;
  background-color: rgb(0, 0, 0, 72%);
  border: 2px solid #000;
  border-radius: 3px;
  box-shadow: #000 0 0 15px -4px;
  color: #ebebeb;

  &:hover {
    background-color: rgb(20, 20, 20, 72%);
    color: white;
    transition: 0.3s;
  }
}
</style>
