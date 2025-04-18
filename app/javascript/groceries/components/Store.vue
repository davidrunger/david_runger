<template lang="pug">
.overflow-auto.hidden-scrollbars.pt-2.pl-8.pr-4.max-h-full
  StoreHeader(:store="store")

  ElButton.mr-2.mt-2(
    @click="initializeTripCheckIn"
    :size="isMobileDevice() ? 'small' : 'default'"
  ) Check in items

  StoreNotes(:store="store")

  NewItemForm(:store="store")

  TransitionGroup.items-list.relative.mt-0.mb-8(
    name="appear-and-disappear-vertically-list"
    tag="ul"
  )
    Item(
      v-for="item in sortedItems"
      :item="item"
      :key="item.id"
      :ownStore="store.own_store"
    )

  CheckInModal

  ManageCheckInStoresModal
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { computed } from 'vue';
import { object } from 'vue-types';

import { helpers, useGroceriesStore } from '@/groceries/store';
import type { Item as ItemType } from '@/groceries/types';
import { isMobileDevice } from '@/lib/is_mobile_device';
import { useModalStore } from '@/lib/modal/store';
import type { Store } from '@/types';

import CheckInModal from './CheckInModal.vue';
import Item from './Item.vue';
import ManageCheckInStoresModal from './ManageCheckInStoresModal.vue';
import NewItemForm from './NewItemForm.vue';
import StoreHeader from './StoreHeader.vue';
import StoreNotes from './StoreNotes.vue';

const props = defineProps({
  store: object<Store>().isRequired,
});

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();

const sortedItems = computed((): ItemType[] => {
  return helpers.sortByName(props.store.items);
});

function initializeTripCheckIn() {
  groceriesStore.addCheckInStore({
    store: groceriesStore.currentStore as Store,
  });
  modalStore.showModal({ modalName: 'check-in-shopping-trip' });
}
</script>
