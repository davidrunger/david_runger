<template lang="pug">
section(v-if="items.length > 0")
  h3.font-bold.mb-2 {{ title }} ({{ items.length }})

  ul.check-in-items-list.text-base.mb-2
    CheckInItem(
      v-for="item in items"
      :key="item.id"
      :item="item"
    )
</template>

<script setup lang="ts">
import type { PropType } from 'vue';

import type { Item } from '@/groceries/types';

import CheckInItem from './CheckInItem.vue';

defineProps({
  items: {
    type: Array as PropType<Array<Item>>,
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
});
</script>
