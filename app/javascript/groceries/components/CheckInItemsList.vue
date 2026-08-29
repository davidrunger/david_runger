<template lang="pug">
section.check-in-section(v-if="items.length > 0")
  h3.check-in-heading.mb-2.font-bold {{ title }} ({{ items.length }})

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

<style lang="scss" scoped>
.check-in-section {
  margin-bottom: 12px;
  padding: 10px 12px 4px;
  background: rgb(223, 231, 215, 42%);
  border: 1px solid rgb(198, 203, 185, 65%);
  border-radius: 13px;
}

.check-in-heading {
  color: var(--groceries-sage-dark);
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 1.05rem;
}
</style>
