<template lang="pug">
.stores-list__item.flex.items-center.justify-between.my-4.py-2.px-4.js-link.text-xl(
  :class="['leading-[1.15]', { selected: store === currentStore }]"
  @click="groceriesStore.selectStore({ store })"
)
  .store-name
    button {{ store.name }}
    LockIcon.ml-2(
      v-if="store.private"
      size="22"
    )
  .delete-button
    a.js-link(
      v-if="store.own_store"
      @click.stop="destroyStore(store)"
    ) &times;
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { LockIcon } from 'vue-tabler-icons';
import { object } from 'vue-types';

import { useGroceriesStore } from '@/groceries/store';
import type { Store } from '@/types';

defineProps({
  store: object<Store>().isRequired,
});

const groceriesStore = useGroceriesStore();

const { currentStore } = storeToRefs(groceriesStore);

function destroyStore(store: Store) {
  const confirmation = window.confirm(
    `Are you sure that you want to delete the ${store.name} store and all of its items?`,
  );

  if (confirmation === true) {
    groceriesStore.deleteStore({ store });
  }
}
</script>

<style lang="scss" scoped>
.stores-list__item {
  background: rgb(255, 255, 255, 50%);

  &.selected {
    background: rgb(255, 255, 255, 75%);
    font-weight: bold;
  }
}
</style>
