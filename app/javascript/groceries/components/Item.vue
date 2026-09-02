<template lang="pug">
li.grocery-item.flex.w-full.items-center(
  :id="`grocery-item-${item.id}`"
  :class="{ highlighted, unneeded: item.needed <= 0 }"
)
  .item-stepper.flex.shrink-0.gap-2.whitespace-nowrap
    button.item-button.increment-button(
      @click="setNeeded(item, item.needed + 1)"
      title="Increment"
    )
      .flex.justify-center
        PlusIcon(:size="ICON_SIZE")
    button.item-button.decrement-button(
      @click="decrement(item)"
      title="Decrement"
    )
      .flex.justify-center
        MinusIcon(:size="ICON_SIZE")
  .min-w-0.flex-1.px-3
    span.item-name
      span(v-html="linkifiedAndSanitizedHtml(item.name)")
    span.item-count(v-if="item.needed > 0") &nbsp;({{ item.needed }})
  .ml-auto.shrink-0
    ElDropdown.item-actions(
      trigger="click"
      placement="bottom-end"
      @command="handleItemAction"
    )
      button.item-button.item-actions-button(
        type="button"
        :aria-label="`Actions for ${item.name}`"
        :disabled="item.deleted"
      )
        .flex.justify-center
          DotsVerticalIcon(:size="ICON_SIZE")
      template(#dropdown)
        ElDropdownMenu
          ElDropdownItem(command="rename") Rename
          ElDropdownItem(
            v-if="ownStore"
            command="manage-availabilities"
          ) Available at...
          ElDropdownItem.delete-menu-item(
            v-if="ownStore"
            command="delete"
            divided
          ) {{ item.store_ids.length > 1 ? 'Delete from all stores' : 'Delete' }}
</template>

<script setup lang="ts">
import { ElDropdown, ElDropdownItem, ElDropdownMenu } from 'element-plus';
import { debounce } from 'es-toolkit';
import { DotsVerticalIcon, MinusIcon, PlusIcon } from 'vue-tabler-icons';
import { bool, object } from 'vue-types';

import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import { linkifiedAndSanitizedHtml } from '@/lib/linkifiedAndSanitizedHtml';

const ICON_SIZE = 17;

const props = defineProps({
  item: object<Item>().isRequired,
  ownStore: bool().isRequired,
  highlighted: bool().isRequired,
});

const emit = defineEmits<{
  manageAvailabilities: [item: Item];
  rename: [item: Item];
}>();

const groceriesStore = useGroceriesStore();

type ItemAction = 'delete' | 'manage-availabilities' | 'rename';

function handleItemAction(action: ItemAction): void {
  if (action === 'manage-availabilities') {
    emit('manageAvailabilities', props.item);
  } else if (action === 'rename') {
    emit('rename', props.item);
  } else if (action === 'delete') {
    groceriesStore.destroyItem({ item: props.item });
  }
}

const debouncedPatchItem = debounce(patchItem, 333);

function decrement(item: Item) {
  const newNeededCount = item.needed - 1;
  if (newNeededCount >= 0) {
    setNeeded(item, newNeededCount);
  }
}

function patchItem(item: Item) {
  groceriesStore.updateItem({ item, attributes: { needed: item.needed } });
  groceriesStore.setCollectingDebounces({ value: false });
}

function setNeeded(item: Item, needed: number) {
  item.needed = needed;
  groceriesStore.setCollectingDebounces({ value: true });
  debouncedPatchItem(item);
}
</script>

<style lang="scss" scoped>
.item-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 31px;
  height: 31px;
  padding: 0;
  color: var(--groceries-sage-dark);
  background: rgb(255, 253, 248, 75%);
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
      background: white;
      border-color: var(--groceries-sage);
    }
  }
}

.increment-button {
  color: #426344;
  background: #edf3e9;
}

.decrement-button {
  color: var(--groceries-berry-dark);
  background: #f8ecef;
  border-color: #dec4cb;
}

.item-actions-button {
  color: var(--groceries-sage-dark);
  background: rgb(223, 231, 215, 70%);
  border-color: var(--groceries-stem);
}

:deep(.delete-menu-item) {
  color: var(--groceries-berry-dark);

  &:not(.is-disabled):hover {
    color: var(--groceries-berry-dark);
    background-color: #f8ecef;
  }
}

.item-name {
  color: #38443d;
  font-weight: 520;
  overflow-wrap: anywhere;

  a {
    color: #84907e;

    &:visited {
      color: #84907e;
    }
  }
}

.item-count {
  color: #69756d;
  font-size: 0.83rem;
  white-space: nowrap;
}

.grocery-item {
  min-height: 48px;
  margin: 7px 0;
  padding: 8px 10px;
  background: rgb(255, 253, 248, 88%);
  border: 1px solid rgb(198, 203, 185, 82%);
  border-radius: 14px;
  box-shadow: 0 3px 12px rgb(66, 84, 65, 8%);
  transition:
    background-color 0.3s ease-in-out,
    border-color 0.3s ease-in-out,
    box-shadow 0.3s ease-in-out,
    transform 0.2s ease;

  /* stylelint-disable media-feature-name-value-no-unknown */
  &:not(.unneeded):hover {
    background: var(--groceries-paper);
    border-color: #acb9a1;
    box-shadow: 0 6px 17px rgb(66, 84, 65, 13%);
    transform: translateY(-1px);

    @media (hover: none), (hover: on-demand) {
      background: rgb(255, 253, 248, 88%);
      border-color: rgb(198, 203, 185, 82%);
      box-shadow: 0 3px 12px rgb(66, 84, 65, 8%);
      transform: none;
    }
  }

  &.unneeded {
    background: rgb(239, 237, 228, 68%);
    border-color: rgb(198, 203, 185, 45%);
    box-shadow: none;
    opacity: 0.7;

    &:hover {
      background: rgb(247, 244, 236, 82%);
      opacity: 0.9;

      @media (hover: none), (hover: on-demand) {
        background: rgb(239, 237, 228, 68%);
        opacity: 0.7;
      }
    }
  }
  /* stylelint-enable media-feature-name-value-no-unknown */

  &.highlighted {
    background: #fbf0d2;
    border-color: #d5b767;
    box-shadow: 0 0 0 4px rgb(213, 183, 103, 25%);
  }
}
</style>
