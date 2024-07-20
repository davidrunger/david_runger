<template lang="pug">
section(v-if="items.length > 0")
  h3.font-bold.mb-2 {{ title }} ({{ items.length }})

  ul.check-in-items-list.text-base.mb-2
    li.flex.items-center.break-word.mb-2(
      v-for='item in items'
      :key='item.id'
      :class='aboutToMoveToClass(item)'
    )
      input(
        type='checkbox'
        :checked='item.in_cart'
        @change='toggleItemInCart(item)'
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
          @click='unskip(item)'
        ) Unskip
        el-button(
          v-else
          link
          type='primary'
          @click='skip(item)'
        ) Skip
</template>

<script lang="ts">
import { defineComponent, PropType } from 'vue';

import { useGroceriesStore } from '@/groceries/store';
import { Item } from '@/groceries/types';

const MOVE_TIMEOUT = 500;
const MOVING_TO_STATUS_TO_CLASS_MAP = {
  'in-cart': 'bg-green-300',
  needed: 'bg-orange-200',
  skipped: 'bg-red-400',
};
const CLEAR_BACKGROUND_COLOR_TIMEOUT = 1200;

export default defineComponent({
  props: {
    items: {
      type: Array as PropType<Array<Item>>,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
  },

  data() {
    return {
      groceriesStore: useGroceriesStore(),
    };
  },

  methods: {
    aboutToMoveToClass(item: Item) {
      if (item.aboutToMoveTo) {
        return MOVING_TO_STATUS_TO_CLASS_MAP[item.aboutToMoveTo];
      }
    },

    skip(item: Item) {
      if (item.aboutToMoveTo) return;

      item.aboutToMoveTo = 'skipped';

      setTimeout(() => {
        this.groceriesStore.skipItem({ item });
      }, MOVE_TIMEOUT);

      setTimeout(() => {
        item.aboutToMoveTo = null;
      }, CLEAR_BACKGROUND_COLOR_TIMEOUT);
    },

    toggleItemInCart(item: Item) {
      if (item.aboutToMoveTo) return;

      item.aboutToMoveTo = item.in_cart ? 'needed' : 'in-cart';

      setTimeout(() => {
        item.in_cart = !item.in_cart;
      }, MOVE_TIMEOUT);

      setTimeout(() => {
        item.aboutToMoveTo = null;
      }, CLEAR_BACKGROUND_COLOR_TIMEOUT);
    },

    unskip(item: Item) {
      if (item.aboutToMoveTo) return;

      item.aboutToMoveTo = 'needed';

      setTimeout(() => {
        this.groceriesStore.unskipItem({ item });
      }, MOVE_TIMEOUT);

      setTimeout(() => {
        item.aboutToMoveTo = null;
      }, CLEAR_BACKGROUND_COLOR_TIMEOUT);
    },
  },
});
</script>

<style lang="scss">
// double class in selector to increase specificity of this override
.el-button.el-button.is-link {
  padding: 0;
  vertical-align: unset;
}

li {
  transition: all 0.15s ease-out;
}
</style>
