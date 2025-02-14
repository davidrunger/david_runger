<template lang="pug">
div.mb-2
  el-input(
    v-if='editingNotes'
    type='textarea'
    placeholder='Member phone number: 619-867-5309'
    v-model='store.notes'
    @blur='stopEditingAndUpdateStoreNotes()'
    ref='storeNotesInput'
  )

  .flex.items-center.mt-2(v-else)
    .whitespace-pre-wrap
      | {{store.notes || 'No notes yet'}}
    div
      a.js-link.text-neutral-400.ml-2(
        v-if='store.own_store'
        @click='editStoreNotes'
        class="hover:text-black"
      )
        EditIcon(size='18')
        |
        | Edit
</template>

<script setup lang="ts">
import { ElInput } from 'element-plus';
import { ref, type PropType } from 'vue';
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
  // wait a tick for input to render, then focus it
  setTimeout(focusStoreNotesInput);
}

function focusStoreNotesInput(callsAlready = 0) {
  if (!editingNotes.value) return;

  if (storeNotesInput.value) {
    (storeNotesInput.value as HTMLInputElement).focus();
  } else if (callsAlready < 20) {
    // the storeNotesInput hasn't had time to render yet; retry later
    setTimeout(() => {
      focusStoreNotesInput(callsAlready + 1);
    }, 50);
  }
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
