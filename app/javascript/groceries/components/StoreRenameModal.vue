<template lang="pug">
Modal(
  :name="modalName"
  width="85%"
  maxWidth="400px"
)
  form.rename-store-form(@submit.prevent="saveStoreName")
    h3.mb-4.font-bold Rename '{{ store.name }}'
    label.store-name-label.block
      | New store name
      input.mt-2.w-full(
        v-model="editableName"
        ref="storeNameInput"
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
import { computed, ref, watch } from 'vue';
import { object } from 'vue-types';

import Modal from '@/components/Modal.vue';
import { useGroceriesStore } from '@/groceries/store';
import { useModalStore } from '@/lib/modal/store';
import type { Store } from '@/types';

const props = defineProps({
  store: object<Store>().isRequired,
});

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
const editableName = ref('');
const modalName = 'rename-grocery-store';
const saving = ref(false);
const storeNameInput = ref<HTMLInputElement | null>(null);

const showingRenameModal = computed(() => {
  return modalStore.showingModal({ modalName });
});

watch(
  showingRenameModal,
  (showing) => {
    if (showing) editableName.value = props.store.name;
  },
  { immediate: true },
);

// On first mount, the modal may already be showing before the input ref exists.
watch(
  storeNameInput,
  (input) => {
    if (showingRenameModal.value) input?.focus();
  },
  { flush: 'post' },
);

function cancel(): void {
  modalStore.hideModal({ modalName });
}

async function saveStoreName(): Promise<void> {
  saving.value = true;

  try {
    await groceriesStore.updateStore({
      store: props.store,
      attributes: { name: editableName.value },
    });
    modalStore.hideModal({ modalName });
  } finally {
    saving.value = false;
  }
}
</script>

<style lang="scss" scoped>
.rename-store-form input {
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
