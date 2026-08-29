<template lang="pug">
h1.store-title.my-1.flex.flex-wrap.items-center
  template(v-if="isEditingName")
    input(
      type="text"
      v-model="editableNameRef"
      ref="nameInputRef"
      v-bind="nameInputEventHandlers"
    )
  template(v-else)
    span {{ store.name }}
  a.edit-store-name.ml-2.inline-flex.cursor-pointer(
    @click="startEditingName(store.name)"
    class="hover:text-black"
  )
    EditIcon(size="27")
  span.inline-flex(v-if="store.own_store")
    ElButton.ml-2(
      v-if="store.private"
      size="small"
      round
      @click="togglePrivacy"
    ) Make public
    ElButton.ml-2(
      v-else
      size="small"
      round
      @click="togglePrivacy"
    ) Make private
  span.spinner--circle.ml-2(class="size-3.5" v-if="debouncingOrWaitingOnNetwork")
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { storeToRefs } from 'pinia';
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
  editableRef: editableNameRef,
  isEditing: isEditingName,
  startEditing: startEditingName,
  inputEventHandlers: nameInputEventHandlers,
} = useCancelableInput({
  onUpdate(newName) {
    groceriesStore.updateStore({
      store: props.store,
      attributes: {
        name: newName,
      },
    });
  },
  refName: 'nameInputRef',
});

const { debouncingOrWaitingOnNetwork } = storeToRefs(groceriesStore);

function togglePrivacy() {
  const targetState = props.store.private ? 'public' : 'private';
  const confirmed = confirm(
    `Are you sure that you want to make '${props.store.name}' ${targetState}?`,
  );

  if (confirmed) {
    groceriesStore.updateStore({
      store: props.store,
      attributes: {
        private: !props.store.private,
      },
    });
  }
}
</script>

<style lang="scss" scoped>
.store-title {
  color: var(--groceries-sage-dark);
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(1.7rem, 4vw, 2.25rem);
  font-weight: 600;
  letter-spacing: -0.025em;
}

.edit-store-name {
  color: #84907e;

  &:visited {
    color: #84907e;
  }

  &:hover {
    color: var(--groceries-berry-dark);
  }
}

input {
  width: min(100%, 380px);
  padding: 7px 11px;
  background: var(--groceries-paper);
  border: 1px solid var(--groceries-stem);
  border-radius: 10px;
  box-shadow: 0 0 0 3px rgb(113, 129, 104, 10%);
}
</style>
