<template lang="pug">
button(
  :class='{editable, selected}'
  @click='handleClick'
)
  span(v-if='selected') {{emoji}}
  span(v-else) {{ratingValue}}
</template>

<script lang='ts'>
import { PropType } from 'vue';
import { sample } from 'lodash-es';
import { assert } from '@/shared/helpers';
import { useCheckInsStore } from '@/check_ins/store';
import { NeedSatisfactionRating, Rating } from '@/check_ins/types';

const EMOJIS = new Map([
  [-3, ['😢']],
  [-2, ['😞']],
  [-1, ['😕']],
  [0, ['😐']],
  [1, ['🙂']],
  [2, ['😀']],
  [3, ['🥰', '😍', '🤩', '😇', '🥳']],
]);

export default {
  computed: {
    emoji(): string {
      return assert(sample(EMOJIS.get(this.ratingValue)));
    },

    selected(): boolean {
      return this.needSatisfactionRating.score === this.ratingValue;
    },
  },

  data() {
    return {
      checkInsStore: useCheckInsStore(),
    };
  },

  methods: {
    handleClick() {
      if (this.editable) {
        this.checkInsStore.updateRating({
          needSatisfactionRating: this.needSatisfactionRating,
          attributes: { score: this.ratingValue },
        });
      }
    },
  },

  props: {
    editable: {
      type: Boolean,
      default: true,
    },
    needSatisfactionRating: {
      type: Object as PropType<NeedSatisfactionRating>,
      required: true,
    },
    ratingValue: {
      type: Number as PropType<Rating>,
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
