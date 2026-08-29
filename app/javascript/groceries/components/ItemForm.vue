<template lang="pug">
form.item-form.flex.items-center.gap-3(@submit.prevent)
  .add-item-icon.flex.shrink-0.items-center.justify-center
    PlusIcon(size="19")
  ElAutocomplete.item-name-input.w-full(
    ref="autocompleteRef"
    v-model="formData.itemName"
    :debounce="0"
    :fetch-suggestions="itemSuggestions"
    :trigger-on-focus="false"
    fit-input-width
    name="itemName"
    placeholder="Add or search items"
    @select="selectSuggestion"
  )
    template(#default="slotProps")
      template(v-if="slotProps.item.type === 'existing'")
        span {{ slotProps.item.value }}
        span.ml-2.text-neutral-500(v-if="slotProps.item.item.needed > 0") &nbsp;({{ slotProps.item.item.needed }})
      span(v-else) Add '{{ slotProps.item.value }}'
</template>

<script setup lang="ts">
import {
  ElAutocomplete,
  type AutocompleteDataItem,
  type AutocompleteFetchSuggestionsCallback,
  type AutocompleteInstance,
} from 'element-plus';
import { nextTick, reactive, ref } from 'vue';
import { PlusIcon } from 'vue-tabler-icons';
import { object } from 'vue-types';

import { helpers, useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import type { Store } from '@/types';

interface ExistingItemSuggestion {
  item: Item;
  type: 'existing';
  value: string;
}

interface AddItemSuggestion {
  type: 'add';
  value: string;
}

type ItemSuggestion = AddItemSuggestion | ExistingItemSuggestion;

const props = defineProps({
  store: object<Store>().isRequired,
});

const groceriesStore = useGroceriesStore();
const autocompleteRef = ref<AutocompleteInstance>();
const emit = defineEmits<{
  itemTargeted: [item: Item];
}>();

const formData = reactive({
  itemName: '',
});

function itemSuggestions(
  queryString: string,
  callback: AutocompleteFetchSuggestionsCallback<ItemSuggestion>,
): void {
  const normalizedQuery = queryString.toLowerCase();
  const existingSuggestions: ExistingItemSuggestion[] = helpers
    .sortByName(props.store.items)
    .filter((item) => item.name.toLowerCase().includes(normalizedQuery))
    .map((item) => ({
      item,
      type: 'existing',
      value: item.name,
    }));

  callback([
    ...existingSuggestions,
    {
      type: 'add',
      value: queryString,
    },
  ]);
}

async function selectSuggestion(
  suggestion: AutocompleteDataItem,
): Promise<void> {
  const itemSuggestion = suggestion as ItemSuggestion;

  if (itemSuggestion.type === 'existing') {
    formData.itemName = '';
    await blurAutocomplete();
    emit('itemTargeted', itemSuggestion.item);
    return;
  }

  const item = await groceriesStore.createItem({
    store: props.store,
    itemAttributes: {
      name: itemSuggestion.value,
    },
  });

  if (item) {
    formData.itemName = '';
    await blurAutocomplete();
    emit('itemTargeted', item);
  }
}

async function blurAutocomplete(): Promise<void> {
  await nextTick();
  autocompleteRef.value?.blur();
}
</script>

<style lang="scss" scoped>
.add-item-icon {
  width: 34px;
  height: 34px;
  color: white;
  background: var(--groceries-sage);
  border-radius: 50%;
  box-shadow: 0 4px 10px rgb(66, 84, 65, 20%);
}

.item-name-input {
  :deep(.el-input__wrapper) {
    padding: 3px 16px;
    background: var(--groceries-paper);
    border: 1px solid var(--groceries-stem);
    border-radius: 999px;
    box-shadow: 0 5px 16px rgb(66, 84, 65, 11%);

    &.is-focus {
      border-color: var(--groceries-sage);
      box-shadow: 0 0 0 3px rgb(113, 129, 104, 14%);
    }
  }
}
</style>
