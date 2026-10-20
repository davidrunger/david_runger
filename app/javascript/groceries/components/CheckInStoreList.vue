<template lang="pug">
ul
  li.mb-2(
    v-for="store in stores"
    :key="store.id"
  )
    label.check-in-store.flex.items-center
      input(
        type="checkbox"
        v-model="groceriesStore.checkInStores"
        :value="store"
        :id="`checkin-stores-${store.id}`"
      )
      span.font-metric-aligned.ml-2 {{ store.name }}
</template>

<script setup lang="ts">
import { array } from 'vue-types';

import { useGroceriesStore } from '@/groceries/store';
import type { Store } from '@/types';

defineProps({
  stores: array<Store>().isRequired,
});

const groceriesStore = useGroceriesStore();
</script>

<style lang="scss" scoped>
.check-in-store {
  min-height: 38px;
  padding: 7px 9px;
  background: rgb(223, 231, 215, 42%);
  border-radius: 9px;
}
</style>
