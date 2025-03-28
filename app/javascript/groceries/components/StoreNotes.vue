<template lang="pug">
.mb-2
  template(v-if="isEditingNotes")
    textarea.mt-2.p-2.w-full.rounded-sm(
      v-model="editableNotesRef"
      placeholder="Member phone number: 619-867-5309"
      v-bind="notesInputEventHandlers"
      ref="notesInputRef"
    )

  template(v-else)
    .flex.items-center.mt-2
      .whitespace-pre-wrap
        | {{ store.notes || 'No notes yet' }}
      div
        a.js-link.text-neutral-400.ml-2(
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
import { useCancellableInput } from '@/lib/composables/useCancellableInput';
import type { Store } from '@/types';

const props = defineProps({
  store: object<Store>().isRequired,
});

const groceriesStore = useGroceriesStore();

const {
  editableRef: editableNotesRef,
  isEditing: isEditingNotes,
  startEditing: startEditingNotes,
  inputRef: notesInputRef,
  inputEventHandlers: notesInputEventHandlers,
} = useCancellableInput({
  onUpdate(newNotes) {
    groceriesStore.updateStore({
      store: props.store,
      attributes: {
        notes: newNotes,
      },
    });
  },
});
</script>
