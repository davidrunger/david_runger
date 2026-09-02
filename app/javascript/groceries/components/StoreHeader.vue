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
  LockIcon.ml-2(
    v-if="store.private"
    aria-label="Private store"
    size="27"
  )
  a.edit-store-name.ml-2.inline-flex.cursor-pointer(
    @click="startEditingName(store.name)"
    class="hover:text-black"
  )
    EditIcon(size="27")
  span.spinner--circle.ml-2(class="size-3.5" v-if="debouncingOrWaitingOnNetwork")
  ElDropdown.store-actions.ml-auto(
    trigger="click"
    placement="bottom-end"
    @command="handleStoreAction"
  )
    button.store-actions-button(
      type="button"
      :aria-label="`Settings for ${store.name}`"
    )
      SettingsIcon(:size="24")
    template(#dropdown)
      ElDropdownMenu
        ElDropdownItem(command="notes") Store notes
        ElDropdownItem(
          v-if="store.own_store"
          command="privacy"
        ) Privacy
</template>

<script setup lang="ts">
import { ElDropdown, ElDropdownItem, ElDropdownMenu } from 'element-plus';
import { storeToRefs } from 'pinia';
import { EditIcon, LockIcon, SettingsIcon } from 'vue-tabler-icons';
import { object } from 'vue-types';

import { useGroceriesStore } from '@/groceries/store';
import { useCancelableInput } from '@/lib/composables/useCancelableInput';
import type { Store } from '@/types';

const props = defineProps({
  store: object<Store>().isRequired,
});

const emit = defineEmits<{
  showPrivacy: [];
  showNotes: [];
}>();

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

function handleStoreAction(action: 'notes' | 'privacy'): void {
  if (action === 'notes') emit('showNotes');
  else if (action === 'privacy') emit('showPrivacy');
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

.store-actions-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  padding: 0;
  color: var(--groceries-sage-dark);
  background: rgb(223, 231, 215, 70%);
  border: 1px solid var(--groceries-stem);
  border-radius: 50%;
  outline: inherit;
  transition:
    background-color 0.18s ease,
    border-color 0.18s ease,
    color 0.18s ease,
    transform 0.18s ease;

  &:active {
    transform: scale(0.92);
  }

  @media (hover: hover) {
    &:hover {
      color: var(--groceries-berry-dark);
      background: white;
      border-color: var(--groceries-sage);
    }
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
