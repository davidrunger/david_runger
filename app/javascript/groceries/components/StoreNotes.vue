<template lang="pug">
.mb-2
  template(v-if="isEditingNotes")
    textarea.mt-2.w-full.rounded-sm.p-2(
      v-model="editableNotesRef"
      placeholder="Member phone number: 619-867-5309"
      v-bind="notesInputEventHandlers"
      ref="notesInputRef"
    )

  template(v-else)
    .mt-2.flex.items-center
      .whitespace-pre-wrap
        | {{ store.notes || 'No notes yet' }}
      div
        a.ml-2.cursor-pointer.text-neutral-400(
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
