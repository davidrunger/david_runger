<template lang="pug">
button.bg-slate-200(
  :class="{ editable, selected }"
  @click="handleClick"
)
  span(v-if="selected") {{ emoji }}
  span(v-else) {{ ratingValue }}
</template>

<script setup lang="ts">
import { sample } from 'lodash-es';
import { computed, type PropType } from 'vue';

import { useCheckInsStore } from '@/check_ins/store';
import type { NeedSatisfactionRating, Rating } from '@/check_ins/types';
import { assert } from '@/shared/helpers';

const EMOJIS = new Map([
  [-3, ['😢']],
  [-2, ['😞']],
  [-1, ['😕']],
  [0, ['😐']],
  [1, ['🙂']],
  [2, ['😀']],
  [3, ['🥰', '😍', '🤩', '😇', '🥳']],
]);

const props = defineProps({
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
});

const checkInsStore = useCheckInsStore();

const emoji = computed((): string => {
  return assert(sample(EMOJIS.get(props.ratingValue)));
});

const selected = computed((): boolean => {
  return props.needSatisfactionRating.score === props.ratingValue;
});

function handleClick() {
  if (props.editable) {
    checkInsStore.updateRating({
      needSatisfactionRating: props.needSatisfactionRating,
      attributes: { score: props.ratingValue },
    });
  }
}
</script>

<style lang="scss" scoped>
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
