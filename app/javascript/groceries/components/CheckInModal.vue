<template lang="pug">
Modal(
  name="check-in-shopping-trip"
  width="85%"
  maxWidth="400px"
)
  slot
    .flex.max-h-full.flex-col
      .check-in-summary.mb-3.flex.shrink-0.items-center
        span Stores: {{ checkInStoreNames }}
        ElButton.choose-stores.ml-2(
          link
          type="primary"
          @click="manageCheckInStores"
        ) Choose stores

      ElButton.mb-3(
        v-if="itemsToOrganize.length > 0"
        type="primary"
        plain
        @click="emit('organizeItems', itemsToOrganize)"
      ) Organize {{ itemsToOrganize.length }} ungrouped {{ itemsToOrganize.length === 1 ? 'item' : 'items' }}

      .flex-1.overflow-y-auto
        CheckInSectionedItemsList(
          :groups="neededItemGroups"
          :items="neededUnskippedCheckInItemsNotInCart"
        )

        CheckInItemsList(
          title="In Cart"
          :items="neededUnskippedCheckInItemsInCart"
        )

        CheckInItemsList(
          title="Skipped"
          :items="neededSkippedCheckInItems"
        )

      .mt-4.flex.shrink-0.justify-around
        ElButton(
          @click="modalStore.hideModal({ modalName: 'check-in-shopping-trip' })"
          type="primary"
          link
        ) Cancel
        ElButton(
          @click="handleTripCheckinModalSubmit"
          type="primary"
          plain
          :disabled="checkingIn"
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

import Modal from '@/components/Modal.vue';
import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import { useModalStore } from '@/lib/modal/store';
import { vueToast } from '@/lib/vueToasts';
import type { Store } from '@/types';

import CheckInItemsList from './CheckInItemsList.vue';
import CheckInSectionedItemsList from './CheckInSectionedItemsList.vue';

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();

const emit = defineEmits<{
  organizeItems: [items: Array<Item>];
}>();

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
const itemsToOrganize = computed(() => {
  return groceriesStore.neededCheckInItems.filter((item) => {
    return groceriesStore.checkInStores.some((store) => {
      if (!item.store_ids.includes(store.id)) return false;

      const configuration = store.section_configuration;
      if (!configuration) return true;
      if (!configuration.sectioning_enabled) return false;

      return !store.item_section_assignments.some(
        (assignment) => assignment.item_id === item.id,
      );
    });
  });
});
const neededItemGroups = computed(() => {
  const groups = new Map<string, Array<Item>>();

  for (const item of neededUnskippedCheckInItemsNotInCart.value) {
    const availableStores = groceriesStore.checkInStores.filter(
      (candidateStore) => item.store_ids.includes(candidateStore.id),
    );
    const store = availableStores.length === 1 ? availableStores[0] : undefined;
    const assignment = store?.item_section_assignments.find(
      (candidateAssignment) => candidateAssignment.item_id === item.id,
    );
    const section =
      store?.section_configuration?.store_section_scheme?.store_sections.find(
        (candidateSection) =>
          candidateSection.id === assignment?.store_section_id,
      );
    const title = section?.name || 'Unsorted';
    groups.set(title, [...(groups.get(title) || []), item]);
  }

  return [...groups.entries()]
    .map(([title, items]) => ({ title, items }))
    .sort((left, right) => {
      if (left.title === 'Unsorted') return 1;
      if (right.title === 'Unsorted') return -1;

      return left.title.localeCompare(right.title);
    });
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
    vueToast('Check-in successful!', {
      toastClassName: 'groceries-toast',
    });
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
    color: var(--groceries-berry-dark);
    background-color: var(--groceries-paper);
  }
}

.check-in-summary {
  padding-bottom: 10px;
  color: var(--groceries-sage-dark);
  border-bottom: 1px solid var(--groceries-stem);
}

@keyframes pulsing {
  $box-shadow-min-width: 4px;
  $box-shadow-max-width: 8px;
  $shadow-color: rgb(214, 176, 186, 55%);

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
