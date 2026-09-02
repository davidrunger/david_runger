<template lang="pug">
.store-scroll.hidden-scrollbars.max-h-full.overflow-auto
  .store-panel
    StoreHeader(
      :store="store"
      @show-notes="showStoreNotes"
      @show-privacy="showStorePrivacyModal"
    )

    .store-actions
      ElButton.check-in-button(
        @click="initializeTripCheckIn"
        :size="isMobileDevice() ? 'small' : 'default'"
        round
        type="primary"
      ) Check in items

    .item-form-container.sticky.top-0.z-10.py-3
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
        @manage-availabilities="showItemAvailabilitiesModal"
        @rename="showRenameItemModal"
      )

  CheckInModal

  ManageCheckInStoresModal

  StoreNotesModal(:store="store")

  StorePrivacyModal(:store="store")

  ItemRenameModal(
    v-if="itemToRename"
    :item="itemToRename"
    @item-merged="scrollToAndHighlightItem"
  )

  ItemAvailabilitiesModal(
    v-if="itemForAvailabilities"
    :item="itemForAvailabilities"
  )
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
import ItemAvailabilitiesModal from './ItemAvailabilitiesModal.vue';
import ItemForm from './ItemForm.vue';
import ItemRenameModal from './ItemRenameModal.vue';
import ManageCheckInStoresModal from './ManageCheckInStoresModal.vue';
import StoreHeader from './StoreHeader.vue';
import StoreNotesModal from './StoreNotesModal.vue';
import StorePrivacyModal from './StorePrivacyModal.vue';

const props = defineProps({
  store: object<Store>().isRequired,
});

useTitle(() => `${props.store.name} - Groceries - David Runger`);

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
const highlightedItemId = ref<number>();
const itemForAvailabilities = ref<ItemType | null>(null);
const itemToRename = ref<ItemType | null>(null);
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

function showItemAvailabilitiesModal(item: ItemType): void {
  itemForAvailabilities.value = item;
  modalStore.showModal({ modalName: 'manage-item-availabilities' });
}

function showRenameItemModal(item: ItemType): void {
  itemToRename.value = item;
  modalStore.showModal({ modalName: 'rename-grocery-item' });
}

function showStoreNotes(): void {
  modalStore.showModal({ modalName: 'store-notes' });
}

function showStorePrivacyModal(): void {
  modalStore.showModal({ modalName: 'store-privacy' });
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

<style lang="scss" scoped>
.store-scroll {
  padding: 22px clamp(14px, 4vw, 52px) 40px;
}

.store-panel {
  width: min(100%, 760px);
  min-height: calc(100% - 10px);
  margin: 0 auto;
  padding: clamp(18px, 3vw, 32px);
  background: rgb(255, 253, 248, 78%);
  border: 1px solid rgb(198, 203, 185, 72%);
  border-radius: 24px;
  box-shadow: 0 18px 45px rgb(66, 84, 65, 13%);
  backdrop-filter: blur(5px);
}

.store-actions {
  margin: 12px 0 10px;
}

.check-in-button {
  box-shadow: 0 5px 14px rgb(117, 64, 82, 18%);
}

.item-form-container {
  margin: 4px -5px 2px;
  padding-right: 5px;
  padding-left: 5px;
  background: linear-gradient(
    to bottom,
    rgb(255, 253, 248, 95%) 0%,
    rgb(255, 253, 248, 88%) 76%,
    rgb(255, 253, 248, 0%) 100%
  );
  border-radius: 18px;
}

@media screen and (width <= 600px) {
  .store-scroll {
    padding: 10px;
  }

  .store-panel {
    padding: 16px 12px 26px;
    border-radius: 18px;
  }
}
</style>
