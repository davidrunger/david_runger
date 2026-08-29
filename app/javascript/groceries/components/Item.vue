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
  .min-w-0.px-3
    template(v-if="isEditing")
      input(
        v-model="nameEditableRef"
        type="text"
        ref="inputRef"
        v-bind="inputEventHandlers"
      )
    template(v-else)
      span.item-name
        span(v-html="linkifiedAndSanitizedHtml(item.name)")
        |
        |
        a.cursor-pointer.text-neutral-400(
          @click="editItemName"
          class="hover:text-black"
        )
          EditIcon(:size="ICON_SIZE")
    | &nbsp;
    span.item-count ({{ item.needed }})
  .ml-auto.cursor-pointer(v-if="ownStore")
    button.item-button.delete-item-button(
      @click="groceriesStore.destroyItem({ item })"
      title="Delete item"
      :disabled="item.deleted"
    )
      .flex.justify-center
        XIcon(:size="ICON_SIZE")
</template>

<script setup lang="ts">
import { debounce } from 'es-toolkit';
import { EditIcon, MinusIcon, PlusIcon, XIcon } from 'vue-tabler-icons';
import { bool, object } from 'vue-types';

import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import { useCancelableInput } from '@/lib/composables/useCancelableInput';
import { linkifiedAndSanitizedHtml } from '@/lib/linkifiedAndSanitizedHtml';

const ICON_SIZE = 17;

const props = defineProps({
  item: object<Item>().isRequired,
  ownStore: bool().isRequired,
  highlighted: bool().isRequired,
});

const groceriesStore = useGroceriesStore();

const {
  editableRef: nameEditableRef,
  isEditing,
  startEditing,
  inputEventHandlers,
} = useCancelableInput({
  onUpdate: (newValue: string) => {
    groceriesStore.updateItem({
      item: props.item,
      attributes: {
        name: newValue,
      },
    });
  },
  refName: 'inputRef',
});

function editItemName(): void {
  startEditing(props.item.name);
}

const debouncedPatchItem = debounce(patchItem, 333);

function decrement(item: Item) {
  const newNeededCount = item.needed - 1;
  if (newNeededCount >= 0) {
    setNeeded(item, newNeededCount);
  }
}

function patchItem(item: Item) {
  groceriesStore.updateItem({ item, attributes: item });
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

.decrement-button,
.delete-item-button {
  color: var(--groceries-berry-dark);
  background: #f8ecef;
  border-color: #dec4cb;
}

.delete-item-button {
  width: 29px;
  height: 29px;
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
  display: inline-block;
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

input {
  max-width: 100%;
  padding: 6px 9px;
  background: var(--groceries-paper);
  border: 1px solid var(--groceries-sage);
  border-radius: 8px;
}
</style>
