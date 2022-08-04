<template lang="pug">
button(
  :class='{editable, selected}'
  @click='handleClick'
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

  methods: {
    handleClick() {
      if (this.editable) {
        this.$emit('setRatingScore', this.ratingValue);
      }
    },
  },

  props: {
    editable: {
      type: Boolean,
      default: true,
    },
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
  cursor: pointer;

  &:not(:hover) {
    background-color: #e9e9ed;
  }

  &.selected {
    background-color: lightblue;
  }

  &:not(.editable):hover {
    background-color: #e9e9ed;
    cursor: default;

    &.selected {
      background-color: lightblue;
    }
  }
}
</style>
