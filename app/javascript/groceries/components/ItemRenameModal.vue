<template lang="pug">
Modal(
  name="rename-grocery-item"
  width="85%"
  maxWidth="400px"
)
  form.rename-item-form(@submit.prevent="saveItemName")
    h3.mb-4.font-bold Rename item
    label.item-name-label.block
      | Item name
      input.mt-2.w-full(
        v-model="editableName"
        ref="itemNameInput"
        type="text"
        autocomplete="off"
      )
    .mt-4.flex.justify-around
      ElButton(
        type="primary"
        link
        @click="cancel"
      ) Cancel
      ElButton(
        type="primary"
        native-type="submit"
        :loading="saving"
      ) Save
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { computed, nextTick, ref, watch } from 'vue';
import { object } from 'vue-types';

import Modal from '@/components/Modal.vue';
import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import { useModalStore } from '@/lib/modal/store';

const props = defineProps({
  item: object<Item>().isRequired,
});

const modalStore = useModalStore();
const groceriesStore = useGroceriesStore();

const editableName = ref('');
const itemNameInput = ref<HTMLInputElement | null>(null);
const saving = ref(false);
const modalName = 'rename-grocery-item';

const showingRenameModal = computed(() => {
  return modalStore.showingModal({ modalName });
});

watch(
  showingRenameModal,
  (showing) => {
    if (!showing) return;

    editableName.value = props.item.name;
    nextTick(() => itemNameInput.value?.focus());
  },
  { immediate: true },
);

function cancel(): void {
  modalStore.hideModal({ modalName });
}

async function saveItemName(): Promise<void> {
  saving.value = true;

  try {
    await groceriesStore.updateItem({
      item: props.item,
      attributes: { name: editableName.value },
    });
    modalStore.hideModal({ modalName });
  } finally {
    saving.value = false;
  }
}
</script>

<style lang="scss" scoped>
.rename-item-form input {
  box-sizing: border-box;
  padding: 8px 11px;
  color: var(--groceries-ink);
  background: var(--groceries-paper);
  border: 1px solid var(--groceries-sage);
  border-radius: 10px;
  outline: none;
  box-shadow: 0 0 0 3px rgb(113, 129, 104, 10%);
}
</style>
