<template lang="pug">
.hidden-scrollbars.max-h-full.overflow-auto.pt-2.pr-4.pl-8
  StoreHeader(:store="store")

  ElButton.mt-2.mr-2(
    @click="initializeTripCheckIn"
    :size="isMobileDevice() ? 'small' : 'default'"
  ) Check in items

  StoreNotes(:store="store")

  .sticky.top-0.z-10.py-2(class="bg-white/80")
    ItemForm(
      :store="store"
      @item-targeted="scrollToAndHighlightItem"
    )

  TransitionGroup.items-list.relative.mt-0.mb-8(
    name="appear-and-disappear-vertically-list"
    tag="ul"
  )
    Item(
      v-for="item in sortedItems"
      :item="item"
      :key="item.id"
      :ownStore="store.own_store"
      :highlighted="item.id === highlightedItemId"
    )

  CheckInModal

  ManageCheckInStoresModal
</template>

<script setup lang="ts">
import { useTitle } from '@vueuse/core';
import { ElButton } from 'element-plus';
import { computed, nextTick, onBeforeUnmount, ref } from 'vue';
import { object } from 'vue-types';

import { helpers, useGroceriesStore } from '@/groceries/store';
import type { Item as ItemType } from '@/groceries/types';
import { isMobileDevice } from '@/lib/isMobileDevice';
import { useModalStore } from '@/lib/modal/store';
import type { Store } from '@/types';

import CheckInModal from './CheckInModal.vue';
import Item from './Item.vue';
import ItemForm from './ItemForm.vue';
import ManageCheckInStoresModal from './ManageCheckInStoresModal.vue';
import StoreHeader from './StoreHeader.vue';
import StoreNotes from './StoreNotes.vue';

const props = defineProps({
  store: object<Store>().isRequired,
});

useTitle(() => `${props.store.name} - Groceries - David Runger`);

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
const highlightedItemId = ref<number>();
let clearHighlightTimeout: ReturnType<typeof setTimeout> | undefined;

const sortedItems = computed((): ItemType[] => {
  return helpers.sortByName(props.store.items);
});

function initializeTripCheckIn() {
  groceriesStore.addCheckInStore({
    store: groceriesStore.currentStore as Store,
  });
  modalStore.showModal({ modalName: 'check-in-shopping-trip' });
}

async function scrollToAndHighlightItem(item: ItemType): Promise<void> {
  highlightedItemId.value = item.id;
  clearTimeout(clearHighlightTimeout);

  await nextTick();
  document.getElementById(`grocery-item-${item.id}`)?.scrollIntoView({
    behavior: 'smooth',
    block: 'center',
  });

  clearHighlightTimeout = setTimeout(() => {
    highlightedItemId.value = undefined;
  }, 2_000);
}

onBeforeUnmount(() => clearTimeout(clearHighlightTimeout));
</script>
