<template lang="pug">
Modal(
  name="store-notes"
  width="85%"
  maxWidth="500px"
)
  form(
    v-if="editing"
    @submit.prevent="saveNotes"
  )
    h3.mb-1.font-bold Edit store notes
    p.mb-4.text-sm.text-neutral-500 {{ store.name }}

    label.block
      span.sr-only Store notes
      textarea.notes-input.w-full.resize-y(
        v-model="editableNotes"
        ref="notesInput"
        rows="6"
        placeholder="Member phone number: 619-867-5309"
      )

    .mt-5.flex.justify-around
      ElButton(
        type="primary"
        link
        @click="cancelEditing"
      ) Cancel
      ElButton(
        type="primary"
        native-type="submit"
        :loading="saving"
      ) Save

  template(v-else)
    h3.mb-1.font-bold Store notes
    p.mb-4.text-sm.text-neutral-500 {{ store.name }}

    .notes-content.whitespace-pre-wrap(v-if="store.notes") {{ store.notes }}
    .empty-notes(v-else) No notes yet.

    .mt-5.flex.justify-around
      ElButton(
        type="primary"
        link
        @click="closeModal"
      ) Close
      ElButton(
        v-if="store.own_store"
        type="primary"
        @click="startEditing"
      ) {{ store.notes ? 'Edit' : 'Add notes' }}
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { computed, nextTick, ref, watch } from 'vue';
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
const modalName = 'store-notes';
const editableNotes = ref('');
const editing = ref(false);
const notesInput = ref<HTMLTextAreaElement | null>(null);
const saving = ref(false);

const showingModal = computed(() => modalStore.showingModal({ modalName }));

watch(showingModal, (showing) => {
  if (showing) editing.value = false;
});

function cancelEditing(): void {
  editing.value = false;
}

function closeModal(): void {
  modalStore.hideModal({ modalName });
}

async function saveNotes(): Promise<void> {
  saving.value = true;

  try {
    await groceriesStore.updateStore({
      store: props.store,
      attributes: { notes: editableNotes.value },
    });
    closeModal();
  } finally {
    saving.value = false;
  }
}

async function startEditing(): Promise<void> {
  editableNotes.value = props.store.notes || '';
  editing.value = true;

  await nextTick();
  notesInput.value?.focus();
}
</script>

<style lang="scss" scoped>
.notes-content,
.empty-notes {
  min-height: 90px;
  padding: 13px 15px;
  color: #586359;
  background: rgb(223, 231, 215, 58%);
  border: 1px solid rgb(181, 194, 171, 58%);
  border-radius: 12px;
  font-size: 0.95rem;
  line-height: 1.5;
}

.empty-notes {
  color: #788177;
  font-style: italic;
}

.notes-input {
  box-sizing: border-box;
  min-height: 120px;
  padding: 11px 13px;
  color: var(--groceries-ink);
  background: var(--groceries-paper);
  border: 1px solid var(--groceries-sage);
  border-radius: 10px;
  outline: none;
  box-shadow: 0 0 0 3px rgb(113, 129, 104, 10%);
}
</style>
