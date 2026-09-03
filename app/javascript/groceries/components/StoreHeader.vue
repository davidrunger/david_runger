<template lang="pug">
h1.store-title.my-1.flex.flex-wrap.items-center
  span {{ store.name }}
  LockIcon.ml-2(
    v-if="store.private"
    aria-label="Private store"
    size="27"
  )
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
        ElDropdownItem(command="sections")
          | Store sections
        ElDropdownItem(
          v-if="store.section_configuration?.sectioning_enabled !== false"
          command="organize-all"
        ) Organize all items
        ElDropdownItem(
          v-if="store.section_configuration?.sectioning_enabled !== false"
          command="organize-needed"
        ) Organize needed items
        ElDropdownItem(
          v-if="store.own_store"
          command="rename"
        ) Rename
        ElDropdownItem(
          v-if="store.own_store"
          command="privacy"
        ) Privacy
</template>

<script setup lang="ts">
import { ElDropdown, ElDropdownItem, ElDropdownMenu } from 'element-plus';
import { storeToRefs } from 'pinia';
import { LockIcon, SettingsIcon } from 'vue-tabler-icons';
import { object } from 'vue-types';

import { useGroceriesStore } from '@/groceries/store';
import type { Store } from '@/types';

const props = defineProps({
  store: object<Store>().isRequired,
});

const emit = defineEmits<{
  organizeAll: [];
  organizeNeeded: [];
  showPrivacy: [];
  showNotes: [];
  showRename: [];
  showSections: [];
}>();

const groceriesStore = useGroceriesStore();

const { debouncingOrWaitingOnNetwork } = storeToRefs(groceriesStore);

function handleStoreAction(
  action:
    | 'notes'
    | 'organize-all'
    | 'organize-needed'
    | 'privacy'
    | 'rename'
    | 'sections',
): void {
  if (action === 'notes') emit('showNotes');
  else if (action === 'organize-all') emit('organizeAll');
  else if (action === 'organize-needed') emit('organizeNeeded');
  else if (action === 'rename') emit('showRename');
  else if (action === 'privacy') emit('showPrivacy');
  else if (action === 'sections') emit('showSections');
}
</script>

<style lang="scss" scoped>
@use 'css/sass_variables' as *;

.store-title {
  color: var(--groceries-sage-dark);
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(1.7rem, 4vw, 2.25rem);
  font-weight: 600;
  letter-spacing: -0.025em;
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

@media screen and (max-width: $small-screen-breakpoint) {
  .store-title {
    padding-left: 50px;
  }
}
</style>
