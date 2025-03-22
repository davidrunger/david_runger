<template lang="pug">
.mb-2
  el-input(
    v-if="editingNotes"
    type="textarea"
    placeholder="Member phone number: 619-867-5309"
    v-model="store.notes"
    @blur="stopEditingAndUpdateStoreNotes()"
    ref="storeNotesInput"
  )

  .flex.items-center.mt-2(v-else)
    .whitespace-pre-wrap
      | {{ store.notes || 'No notes yet' }}
    div
      a.js-link.text-neutral-400.ml-2(
        v-if="store.own_store"
        @click="editStoreNotes"
        class="hover:text-black"
      )
        EditIcon(size="18")
        |
        | Edit
</template>

<script setup lang="ts">
import { ElInput } from 'element-plus';
import { nextTick, ref, type PropType } from 'vue';
import { EditIcon } from 'vue-tabler-icons';

import { useGroceriesStore } from '@/groceries/store';
import type { Store } from '@/types';

const props = defineProps({
  store: {
    type: Object as PropType<Store>,
    required: true,
  },
});

const groceriesStore = useGroceriesStore();

const editingNotes = ref(false);
const storeNotesInput = ref(null);

function editStoreNotes() {
  editingNotes.value = true;
  // Wait a tick for input to render, then focus it.
  nextTick(focusStoreNotesInput);
}

function focusStoreNotesInput() {
  if (!editingNotes.value) return;

  nextTick(() => {
    if (storeNotesInput.value) {
      (storeNotesInput.value as HTMLInputElement).focus();
    }
  });
}

function stopEditingAndUpdateStoreNotes() {
  editingNotes.value = false;
  groceriesStore.updateStore({
    store: props.store,
    attributes: {
      notes: props.store.notes,
    },
  });
}
</script>
