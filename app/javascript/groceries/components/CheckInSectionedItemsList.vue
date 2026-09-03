<template lang="pug">
section.check-in-section(v-if="items.length > 0")
  h3.check-in-heading.mb-2.font-bold Needed ({{ items.length }})

  template(
    v-for="group in groups"
    :key="group.title"
  )
    h4.check-in-subheading.mt-3.mb-1 {{ group.title }}
    ul.check-in-items-list.mb-2.text-base
      CheckInItem(
        v-for="item in group.items"
        :key="item.id"
        :item="item"
      )
</template>

<script setup lang="ts">
import { array } from 'vue-types';

import type { Item } from '@/groceries/types';

import CheckInItem from './CheckInItem.vue';

defineProps({
  groups: array<{ items: Array<Item>; title: string }>().isRequired,
  items: array<Item>().isRequired,
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

.check-in-subheading {
  color: var(--groceries-sage-dark);
  font-size: 0.95rem;
}
</style>
