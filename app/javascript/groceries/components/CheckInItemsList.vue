<template lang="pug">
section(v-if="items.length > 0")
  h3.font-bold.mb-2 {{ title }} ({{ items.length }})

  ul.check-in-items-list.text-base.mb-2
    li.flex.items-center.break-word.mb-2(
      v-for='item in items'
      :key='item.id'
    )
      input(
        type='checkbox'
        v-model='item.in_cart'
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

export default defineComponent({
  data() {
    return {
      groceriesStore: useGroceriesStore(),
    };
  },

  methods: {
    skip(item: Item) {
      this.groceriesStore.skipItem({ item });
    },

    unskip(item: Item) {
      this.groceriesStore.unskipItem({ item });
    },
  },

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
});
</script>

<style lang="scss">
// double class in selector to increase specificity of this override
.el-button.el-button.is-link {
  padding: 0;
  vertical-align: unset;
}
</style>
