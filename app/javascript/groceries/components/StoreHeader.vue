<template lang="pug">
h2.store-name.my-4
  input(
    v-if="editingName"
    type="text"
    v-model="store.name"
    @blur="stopEditingAndUpdateStoreName()"
    @keydown.enter="stopEditingAndUpdateStoreName()"
    ref="storeNameInput"
  )
  span(v-if="!editingName") {{ store.name }}
  a.js-link.text-neutral-400.ml-2(@click="editStoreName" class="hover:text-black")
    EditIcon(size="27")
  span(v-if="store.own_store")
    el-button.ml-2(
      v-if="store.private"
      size="small"
      @click="togglePrivacy"
    ) Make public
    el-button.ml-2(
      v-else
      size="small"
      @click="togglePrivacy"
    ) Make private
  span.spinner--circle.ml-2(v-if="debouncingOrWaitingOnNetwork")
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { storeToRefs } from 'pinia';
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

const { debouncingOrWaitingOnNetwork } = storeToRefs(groceriesStore);

const editingName = ref(false);
const storeNameInput = ref(null);

function editStoreName() {
  editingName.value = true;
  // wait a tick for input to render, then focus it
  setTimeout(focusStoreNameInput);
}

function focusStoreNameInput(callsAlready = 0) {
  if (!editingName.value) return;

  if (storeNameInput.value) {
    (storeNameInput.value as HTMLInputElement).focus();
  } else if (callsAlready < 20) {
    // the storeNameInput hasn't had time to render yet; retry later
    setTimeout(() => {
      focusStoreNameInput(callsAlready + 1);
    }, 50);
  }
}

function stopEditingAndUpdateStoreName() {
  editingName.value = false;
  groceriesStore.updateStore({
    store: props.store,
    attributes: {
      name: props.store.name,
    },
  });
}

function togglePrivacy() {
  groceriesStore.updateStore({
    store: props.store,
    attributes: {
      private: !props.store.private,
    },
  });
}
</script>

<style scoped lang="scss">
.spinner--circle {
  height: 14px;
  width: 14px;
}
</style>
