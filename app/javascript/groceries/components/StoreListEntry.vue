<template lang="pug">
.stores-list__item.my-4.flex.cursor-pointer.items-center.justify-between.px-4.py-2.text-xl(
  class="bg-white/50 leading-[1.15]"
  :class="{ 'bg-white/75 font-bold': store === currentStore }"
  @click="groceriesStore.selectStore({ store })"
)
  .store-name
    button.text-left {{ store.name }}
    LockIcon.ml-2(
      v-if="store.private"
      size="22"
    )
  .delete-button
    a.cursor-pointer(
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
