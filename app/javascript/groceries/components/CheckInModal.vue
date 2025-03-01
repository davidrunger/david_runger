<template lang="pug">
Modal(name="check-in-shopping-trip", width="85%", maxWidth="400px")
  slot
    .flex.flex-col.max-h-full
      .shrink-0.flex.items-center.mb-3
        span Stores: {{ checkInStoreNames }}
        el-button.choose-stores.ml-2(
          link,
          type="primary",
          @click="manageCheckInStores"
        ) Choose stores

      .flex-1.overflow-y-auto
        CheckInItemsList(
          title="Needed",
          :items="neededUnskippedCheckInItemsNotInCart"
        )

        CheckInItemsList(
          title="In Cart",
          :items="neededUnskippedCheckInItemsInCart"
        )

        CheckInItemsList(title="Skipped", :items="neededSkippedCheckInItems")

      .shrink-0.flex.justify-around.mt-4
        el-button(
          @click="modalStore.hideModal({ modalName: 'check-in-shopping-trip' })",
          type="primary",
          link
        ) Cancel
        el-button(
          @click="handleTripCheckinModalSubmit",
          type="primary",
          plain,
          :disabled="checkingIn",
          :class="{ pulsing: noMoreNeededItems() }"
        )
          span(v-if="checkingIn") Checking in...
          span(v-else) Check in items in cart
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { storeToRefs } from 'pinia';
import { computed, ref } from 'vue';
import { TYPE } from 'vue-toastification';

import { useGroceriesStore } from '@/groceries/store';
import { vueToast } from '@/lib/vue_toasts';
import { useModalStore } from '@/shared/modal/store';
import type { Store } from '@/types';

import CheckInItemsList from './CheckInItemsList.vue';

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();

const checkingIn = ref(false);

const {
  neededSkippedCheckInItems,
  neededUnskippedCheckInItemsInCart,
  neededUnskippedCheckInItemsNotInCart,
} = storeToRefs(groceriesStore);

const checkInStoreNames = computed((): string => {
  return groceriesStore.checkInStores
    .map((store: Store) => store.name)
    .join(', ');
});

function noMoreNeededItems() {
  const itemsStillNeeded = groceriesStore.neededCheckInItems.filter(
    (item) =>
      ((item.checkInStatus === 'needed' || !item.checkInStatus) &&
        !item.aboutToMoveTo) ||
      item.aboutToMoveTo === 'needed',
  );

  return itemsStillNeeded.length === 0;
}

async function handleTripCheckinModalSubmit() {
  checkingIn.value = true;

  try {
    await groceriesStore.zeroItemsInCart();
    vueToast('Check-in successful!');
  } catch {
    vueToast('Something went wrong.', { type: TYPE.ERROR });
  }

  checkingIn.value = false;
  modalStore.hideModal({ modalName: 'check-in-shopping-trip' });
}

function manageCheckInStores() {
  modalStore.showModal({ modalName: 'manage-check-in-stores' });
}
</script>

<style lang="scss">
.pulsing.pulsing {
  animation: pulsing 1s ease infinite;

  &:not(:hover) {
    color: rgb(0, 109, 218);
    background-color: white;
  }
}

@keyframes pulsing {
  $box-shadow-min-width: 4px;
  $box-shadow-max-width: 8px;
  $shadow-color: rgb(210, 231, 250);

  0% {
    box-shadow: 0 0 0 $box-shadow-min-width $shadow-color;
  }

  50% {
    box-shadow: 0 0 0 $box-shadow-max-width $shadow-color;
  }

  100% {
    box-shadow: 0 0 0 $box-shadow-min-width $shadow-color;
  }
}
</style>
