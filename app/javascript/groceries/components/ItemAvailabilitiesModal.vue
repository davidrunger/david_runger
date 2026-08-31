<template lang="pug">
Modal(
  :name="modalName"
  width="85%"
  maxWidth="400px"
)
  form(@submit.prevent="saveAvailabilities")
    h3.mb-2.font-bold Available at
    p.mb-4.text-sm.text-neutral-500 Check the stores where you might buy {{ item.name }}.

    ul.store-options
      li(
        v-for="store in groceriesStore.sortedStores"
        :key="store.id"
      )
        label.flex.cursor-pointer.items-center.gap-3
          input(
            v-model="selectedStoreIds"
            type="checkbox"
            :value="store.id"
          )
          span {{ store.name }}

    p.mt-3.text-sm.text-red-700(v-if="selectedStoreIds.length === 0") Choose at least one store.

    .mt-5.flex.justify-around
      ElButton(
        type="primary"
        link
        @click="cancel"
      ) Cancel
      ElButton(
        type="primary"
        native-type="submit"
        :disabled="selectedStoreIds.length === 0"
        :loading="saving"
      ) Save
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { computed, ref, watch } from 'vue';
import { object } from 'vue-types';

import Modal from '@/components/Modal.vue';
import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import { useModalStore } from '@/lib/modal/store';

const props = defineProps({
  item: object<Item>().isRequired,
});

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
const modalName = 'manage-item-availabilities';
const saving = ref(false);
const selectedStoreIds = ref<Array<number>>([]);

const showingModal = computed(() => modalStore.showingModal({ modalName }));

watch(
  showingModal,
  (showing) => {
    if (showing) selectedStoreIds.value = [...props.item.store_ids];
  },
  { immediate: true },
);

function cancel(): void {
  modalStore.hideModal({ modalName });
}

async function saveAvailabilities(): Promise<void> {
  if (selectedStoreIds.value.length === 0) return;

  saving.value = true;

  try {
    await groceriesStore.updateItem({
      item: props.item,
      attributes: { store_ids: selectedStoreIds.value },
    });
    modalStore.hideModal({ modalName });
  } finally {
    saving.value = false;
  }
}
</script>

<style lang="scss" scoped>
.store-options {
  display: grid;
  gap: 8px;

  li {
    padding: 9px 11px;
    background: rgb(223, 231, 215, 42%);
    border: 1px solid rgb(198, 203, 185, 55%);
    border-radius: 10px;
  }
}
</style>
