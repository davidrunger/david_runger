<template lang="pug">
section(v-if="items.length > 0")
  h3.mb-2.font-bold {{ title }} ({{ items.length }})

  ul.check-in-items-list.mb-2.text-base
    CheckInItem(
      v-for="item in items"
      :key="item.id"
      :item="item"
    )
</template>

<script setup lang="ts">
import { array, string } from 'vue-types';

import type { Item } from '@/groceries/types';

import CheckInItem from './CheckInItem.vue';

defineProps({
  items: array<Item>().isRequired,
  title: string().isRequired,
});
</script>
