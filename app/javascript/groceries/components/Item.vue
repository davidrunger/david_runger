<template lang="pug">
.grocery-item.flex.items-center.w-full(:class="{ unneeded: item.needed <= 0 }")
  .left.whitespace-nowrap
    button.item-button.js-link.text-green-600(
      @click="setNeeded(item, item.needed + 1)"
      title="Increment"
    )
      .flex.justify-center
        PlusIcon(:size="ICON_SIZE")
    button.item-button.mx-2.js-link.text-red-600(
      @click="decrement(item)"
      title="Decrement"
    )
      .flex.justify-center
        MinusIcon(:size="ICON_SIZE")
  .left
    input(
      v-if="editingName"
      type="text"
      :value="item.name"
      @blur="stopEditingAndUpdateItemName"
      @keydown.enter="stopEditingAndUpdateItemName"
      @keydown.escape="editingName = false"
      ref="itemNameInput"
    )
    span.item-name(v-else)
      span(v-html="linkify(item.name)")
      |
      |
      a.js-link.text-neutral-400(@click="editItemName" class="hover:text-black")
        EditIcon(:size="ICON_SIZE")
    | &nbsp;
    span ({{ item.needed }})
  .ml-auto.js-link.text-red-500(v-if="ownStore")
    button.item-button(
      @click="groceriesStore.destroyItem({ item })"
      title="Delete item"
    )
      .flex.justify-center
        XIcon(:size="ICON_SIZE")
</template>

<script setup lang="ts">
import { debounce } from 'lodash-es';
import { ref, type PropType } from 'vue';
import { EditIcon, MinusIcon, PlusIcon, XIcon } from 'vue-tabler-icons';

import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import { linkify } from '@/lib/linkify';

const ICON_SIZE = 17;

const props = defineProps({
  item: {
    type: Object as PropType<Item>,
    required: true,
  },
  ownStore: {
    required: true,
    type: Boolean,
  },
});

const editingName = ref(false);
const groceriesStore = useGroceriesStore();
const itemNameInput = ref(null);

const debouncedPatchItem = debounce(patchItem, 333);

function decrement(item: Item) {
  const newNeededCount = item.needed - 1;
  if (newNeededCount >= 0) {
    setNeeded(item, newNeededCount);
  }
}

function editItemName() {
  editingName.value = true;
  // wait a tick for input to render, then focus it
  setTimeout(() => {
    if (itemNameInput.value) {
      (itemNameInput.value as HTMLInputElement).focus();
    }
  });
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

function stopEditingAndUpdateItemName() {
  if (!itemNameInput.value) return; // was happening for me in Chrome in development

  editingName.value = false;
  groceriesStore.updateItem({
    item: props.item,
    attributes: {
      name: (itemNameInput.value as HTMLInputElement).value,
    },
  });
}
</script>

<style lang="scss" scoped>
.item-button {
  border: none;
  border: 1px solid silver;
  font-size: 20px;
  font-weight: bold;
  vertical-align: middle;
  padding: 0;
  cursor: pointer;
  outline: inherit;
  height: 25px;
  width: 35px;
  border-radius: 3px;
  background: none;

  span {
    position: relative;
    top: -1px;
  }

  @media (hover: hover) {
    &:hover {
      background: white;
    }
  }
}

.item-name {
  overflow-wrap: anywhere;
}

.grocery-item {
  background: rgba(255, 255, 255, 60%);
  margin: 5px 0;
  padding: 6px;
  min-height: 30px;

  /* stylelint-disable media-feature-name-value-no-unknown */
  &:not(.unneeded):hover {
    background: rgba(255, 255, 255, 80%);

    @media (hover: none), (hover: on-demand) {
      background: rgba(255, 255, 255, 60%);
    }
  }

  &.unneeded {
    background: rgba(255, 255, 255, 30%);
    color: rgba(0, 0, 0, 55%);

    &:hover {
      background: rgba(255, 255, 255, 50%);

      @media (hover: none), (hover: on-demand) {
        background: rgba(255, 255, 255, 30%);
      }
    }
  }
  /* stylelint-enable media-feature-name-value-no-unknown */
}
</style>
