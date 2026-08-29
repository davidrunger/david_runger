<template lang="pug">
.stores-list__item.my-2.flex.cursor-pointer.items-center.justify-between.px-4.py-3(
  :class="{ selected: store === currentStore }"
  @click="groceriesStore.selectStore({ store })"
)
  .store-name.flex.min-w-0.items-center
    button.truncate.text-left {{ store.name }}
    LockIcon.ml-2(
      v-if="store.private"
      size="22"
    )
  .delete-button.ml-2
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

<style lang="scss" scoped>
.stores-list__item {
  color: #344039;
  background: rgb(255, 253, 248, 72%);
  border: 1px solid rgb(255, 255, 255, 30%);
  border-radius: 14px;
  box-shadow: 0 3px 10px rgb(42, 57, 44, 10%);
  transition:
    background-color 0.2s ease,
    box-shadow 0.2s ease,
    transform 0.2s ease;

  &:hover {
    background: rgb(255, 253, 248, 90%);
    box-shadow: 0 5px 14px rgb(42, 57, 44, 15%);
    transform: translateX(2px);
  }

  &.selected {
    color: #754052;
    background: #fffaf3;
    border-color: #d6b0ba;
    box-shadow:
      inset 4px 0 #96576a,
      0 5px 16px rgb(42, 57, 44, 16%);
    font-weight: 700;
  }
}

.store-name button {
  padding-block: 1px;
  line-height: 1.35;
}

.delete-button a {
  color: #96576a;
  font-size: 1.45rem;
  line-height: 1;

  &:visited {
    color: #96576a;
  }

  &:hover {
    color: #754052;
  }
}
</style>
