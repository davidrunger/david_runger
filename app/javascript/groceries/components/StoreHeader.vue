<template lang="pug">
h1.h2.store-name.my-4
  template(v-if="isEditingName")
    input(
      type="text"
      v-model="editableNameRef"
      ref="nameInputRef"
      v-bind="nameInputEventHandlers"
    )
  template(v-else)
    span {{ store.name }}
  a.js-link.text-neutral-400.ml-2(
    @click="startEditingName(store.name)"
    class="hover:text-black"
  )
    EditIcon(size="27")
  span(v-if="store.own_store")
    ElButton.ml-2(
      v-if="store.private"
      size="small"
      @click="togglePrivacy"
    ) Make public
    ElButton.ml-2(
      v-else
      size="small"
      @click="togglePrivacy"
    ) Make private
  span.spinner--circle.ml-2(v-if="debouncingOrWaitingOnNetwork")
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { storeToRefs } from 'pinia';
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
  editableRef: editableNameRef,
  isEditing: isEditingName,
  startEditing: startEditingName,
  inputRef: nameInputRef,
  inputEventHandlers: nameInputEventHandlers,
} = useCancellableInput({
  onUpdate(newName) {
    groceriesStore.updateStore({
      store: props.store,
      attributes: {
        name: newName,
      },
    });
  },
});

const { debouncingOrWaitingOnNetwork } = storeToRefs(groceriesStore);

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
