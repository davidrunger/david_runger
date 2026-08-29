<template lang="pug">
.store-notes.mb-2
  template(v-if="isEditingNotes")
    textarea.w-full.p-3(
      v-model="editableNotesRef"
      placeholder="Member phone number: 619-867-5309"
      v-bind="notesInputEventHandlers"
      ref="notesInputRef"
    )

  template(v-else)
    .flex.items-center
      .note-content.whitespace-pre-wrap
        | {{ store.notes || 'No notes yet' }}
      div
        a.edit-notes.ml-3.cursor-pointer(
          v-if="store.own_store"
          @click="startEditingNotes(store.notes || '')"
          class="hover:text-black"
        )
          EditIcon(size="18")
          |
          | Edit
</template>

<script setup lang="ts">
import { EditIcon } from 'vue-tabler-icons';
import { object } from 'vue-types';

import { useGroceriesStore } from '@/groceries/store';
import { useCancelableInput } from '@/lib/composables/useCancelableInput';
import type { Store } from '@/types';

const props = defineProps({
  store: object<Store>().isRequired,
});

const groceriesStore = useGroceriesStore();

const {
  editableRef: editableNotesRef,
  isEditing: isEditingNotes,
  startEditing: startEditingNotes,
  inputEventHandlers: notesInputEventHandlers,
} = useCancelableInput({
  onUpdate(newNotes) {
    groceriesStore.updateStore({
      store: props.store,
      attributes: {
        notes: newNotes,
      },
    });
  },
  refName: 'notesInputRef',
});
</script>

<style lang="scss" scoped>
.store-notes {
  margin-top: 10px;
  padding: 11px 14px;
  color: #586359;
  background: rgb(223, 231, 215, 58%);
  border: 1px solid rgb(181, 194, 171, 58%);
  border-radius: 13px;
}

.note-content {
  font-size: 0.92rem;
  line-height: 1.4;
}

.edit-notes {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  color: var(--groceries-berry-dark);
  font-size: 0.85rem;
  font-weight: 600;
  white-space: nowrap;

  &:visited {
    color: var(--groceries-berry-dark);
  }

  &:hover {
    color: var(--groceries-berry);
  }
}

textarea {
  min-height: 74px;
  color: var(--groceries-ink);
  background: var(--groceries-paper);
  border: 1px solid var(--groceries-sage);
  border-radius: 10px;
  outline: none;
  box-shadow: 0 0 0 3px rgb(113, 129, 104, 10%);
}
</style>
