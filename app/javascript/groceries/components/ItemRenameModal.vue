<template lang="pug">
Modal(
  :name="modalName"
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
        :aria-invalid="errors.length > 0"
        :class="{ 'has-errors': errors.length > 0 }"
      )
    .rename-error.mt-3.text-sm.text-red-700(
      v-if="errors.length > 0 && !mergeTarget"
      aria-live="polite"
    ) {{ errorMessage }}
    .merge-explanation.mt-4(
      v-if="mergeTarget"
      aria-live="polite"
    )
      p.font-medium An item named "{{ mergeTarget.name }}" already exists at {{ targetStoreNames }}.
      p.mt-2.text-sm Combining them will make "{{ mergeTarget.name }}" available at {{ combinedStoreNames }} and keep the highest needed amount ({{ combinedNeeded }}).
      p.mt-2.text-sm.font-medium This cannot be undone.
    .mt-4.flex.justify-around
      ElButton(
        type="primary"
        link
        @click="cancel"
      ) Cancel
      ElButton(
        v-if="mergeTarget"
        type="primary"
        :loading="saving"
        @click="combineItems"
      ) Combine items
      ElButton(
        v-else
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
import type { Item, ItemUpdateErrorResponse } from '@/groceries/types';
import { conjunctionList } from '@/lib/helpers';
import { useModalStore } from '@/lib/modal/store';
import { isObjectWithErrors } from '@/lib/typePredicates';

const props = defineProps({
  item: object<Item>().isRequired,
});

const emit = defineEmits<{
  itemMerged: [item: Item];
}>();

const modalStore = useModalStore();
const groceriesStore = useGroceriesStore();

const editableName = ref('');
const errors = ref<Array<string>>([]);
const itemNameInput = ref<HTMLInputElement | null>(null);
const mergeTarget = ref<Item | null>(null);
const nameConflict = ref(false);
const saving = ref(false);
const modalName = 'rename-grocery-item';

const showingRenameModal = computed(() => {
  return modalStore.showingModal({ modalName });
});

const combinedNeeded = computed(() => {
  if (!mergeTarget.value) return props.item.needed;

  return Math.max(props.item.needed, mergeTarget.value.needed);
});

const combinedStoreNames = computed(() => {
  if (!mergeTarget.value) return '';

  const storeIds = new Set([
    ...props.item.store_ids,
    ...mergeTarget.value.store_ids,
  ]);
  return conjunctionList(
    groceriesStore.own_stores
      .filter((store) => storeIds.has(store.id))
      .map((store) => store.name)
      .sort((first, second) => first.localeCompare(second)),
  );
});

const errorMessage = computed(() => {
  if (nameConflict.value) {
    return 'That name is already taken. Choose a different name.';
  }

  return errors.value.join(' ');
});

const targetStoreNames = computed(() => {
  if (!mergeTarget.value) return '';

  return conjunctionList(groceriesStore.itemOwnStoreNames(mergeTarget.value));
});

watch(
  showingRenameModal,
  (showing) => {
    if (!showing) return;

    editableName.value = props.item.name;
    clearErrors();
    nextTick(() => itemNameInput.value?.focus());
  },
  { immediate: true },
);

watch(editableName, clearErrors);

function cancel(): void {
  modalStore.hideModal({ modalName });
}

function clearErrors(): void {
  errors.value = [];
  mergeTarget.value = null;
  nameConflict.value = false;
}

async function combineItems(): Promise<void> {
  if (!mergeTarget.value) return;

  saving.value = true;

  try {
    const mergedItem = await groceriesStore.mergeItems({
      sourceItem: props.item,
      targetItem: mergeTarget.value,
    });
    if (isObjectWithErrors(mergedItem)) {
      errors.value = mergedItem.errors;
      mergeTarget.value = null;
      return;
    }

    modalStore.hideModal({ modalName });
    emit('itemMerged', mergedItem);
  } finally {
    saving.value = false;
  }
}

async function saveItemName(): Promise<void> {
  saving.value = true;

  try {
    const result = await groceriesStore.updateItem({
      item: props.item,
      attributes: { name: editableName.value },
    });
    if (isObjectWithErrors(result)) {
      const updateError = result as ItemUpdateErrorResponse;
      errors.value = updateError.errors;
      mergeTarget.value = updateError.merge_target || null;
      nameConflict.value = updateError.name_conflict || false;
      return;
    }

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

  &.has-errors {
    border-color: var(--groceries-berry-dark);
    box-shadow: 0 0 0 3px rgb(117, 64, 82, 12%);
  }
}

.merge-explanation {
  padding: 12px 14px;
  color: #38443d;
  background: rgb(248, 236, 239, 62%);
  border: 1px solid #dec4cb;
  border-radius: 10px;
}
</style>
