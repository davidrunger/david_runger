<template lang="pug">
li.flex.items-center.break-word.mb-2(
  :class='aboutToMoveToClass()'
)
  input(
    type='checkbox'
    :checked='item.in_cart'
    @change='toggleItemInCart'
    :disabled='item.skipped'
    :id='`trip-checkin-item-${item.id}`'
  )
  label.ml-2(:for='`trip-checkin-item-${item.id}`')
    span(:class='{ "text-gray-500": item.skipped }')
      span {{item.name}}
      span(v-if='item.needed > 1') {{' '}} ({{item.needed}})
    span {{ ' ' }}
    el-button(
      v-if="item.skipped"
      link
      type='primary'
      @click='unskip'
    ) Unskip
    el-button(
      v-else
      link
      type='primary'
      @click='skip'
    ) Skip
</template>

<script setup lang="ts">
import type { PropType } from 'vue';

import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';

const props = defineProps({
  item: {
    type: Object as PropType<Item>,
    required: true,
  },
});

const MOVE_TIMEOUT = 500;
const MOVING_TO_STATUS_TO_CLASS_MAP = {
  'in-cart': 'bg-green-200',
  needed: 'bg-orange-200',
  skipped: 'bg-red-200',
};
const CLEAR_BACKGROUND_COLOR_TIMEOUT = 1200;

const groceriesStore = useGroceriesStore();

function aboutToMoveToClass() {
  if (props.item.aboutToMoveTo) {
    return MOVING_TO_STATUS_TO_CLASS_MAP[props.item.aboutToMoveTo];
  }
}

function skip() {
  if (props.item.aboutToMoveTo) return;

  groceriesStore.setItemAboutToMoveTo({
    item: props.item,
    aboutToMoveTo: 'skipped',
  });

  setTimeout(() => {
    groceriesStore.skipItem({ item: props.item });
  }, MOVE_TIMEOUT);

  setTimeout(() => {
    groceriesStore.setItemAboutToMoveTo({
      item: props.item,
      aboutToMoveTo: null,
    });
  }, CLEAR_BACKGROUND_COLOR_TIMEOUT);
}

function toggleItemInCart() {
  if (props.item.aboutToMoveTo) return;

  groceriesStore.setItemAboutToMoveTo({
    item: props.item,
    aboutToMoveTo: props.item.in_cart ? 'needed' : 'in-cart',
  });

  setTimeout(() => {
    groceriesStore.setItemInCart({
      item: props.item,
      inCart: !props.item.in_cart,
    });
  }, MOVE_TIMEOUT);

  setTimeout(() => {
    groceriesStore.setItemAboutToMoveTo({
      item: props.item,
      aboutToMoveTo: null,
    });
  }, CLEAR_BACKGROUND_COLOR_TIMEOUT);
}

function unskip() {
  if (props.item.aboutToMoveTo) return;

  groceriesStore.setItemAboutToMoveTo({
    item: props.item,
    aboutToMoveTo: 'needed',
  });

  setTimeout(() => {
    groceriesStore.unskipItem({ item: props.item });
  }, MOVE_TIMEOUT);

  setTimeout(() => {
    groceriesStore.setItemAboutToMoveTo({
      item: props.item,
      aboutToMoveTo: null,
    });
  }, CLEAR_BACKGROUND_COLOR_TIMEOUT);
}
</script>

<style scoped lang="scss">
li {
  transition: all 0.15s ease-out;
}

// double class in selector to increase specificity of this override
.el-button.el-button.is-link {
  padding: 0;
  vertical-align: unset;
}
</style>
