<template lang="pug">
button(
  :class='{selected}'
  @click='$emit("setRatingScore", ratingValue);'
)
  span(v-if='selected') {{emoji}}
  span(v-else) {{ratingValue}}
</template>

<script>
import { sample } from 'lodash-es';

export default {
  computed: {
    emoji() {
      return sample(this.emojis);
    },

    selected() {
      return this.needSatisfactionRating.score === this.ratingValue;
    },
  },

  props: {
    emojis: {
      type: Array,
      required: true,
    },
    needSatisfactionRating: {
      type: Object,
      required: true,
    },
    ratingValue: {
      type: Number,
      required: true,
    },
  },
};
</script>

<style lang='scss' scoped>
button {
  width: 40px;
  height: 30px;
  border-radius: 20px;
  border: none;
  margin: 0 1px;
  padding: 5px;

  &.selected {
    background-color: lightblue;
  }
}
</style>
