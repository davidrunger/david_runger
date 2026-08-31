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
    popper-class="grocery-item-suggestions"
    @select="selectSuggestion"
  )
    template(#default="slotProps")
      template(v-if="slotProps.item.type === 'item-in-current-store'")
        span {{ slotProps.item.value }}
        span.ml-1.text-neutral-500(v-if="slotProps.item.item.needed > 0") &nbsp;({{ slotProps.item.item.needed }})
      template(v-else-if="slotProps.item.type === 'item-in-other-store'")
        span Add '{{ slotProps.item.value }}' to {{ props.store.name }}
        span.ml-1.text-neutral-500(v-if="slotProps.item.item.needed > 0") &nbsp;({{ slotProps.item.item.needed }})
        small.block.text-neutral-500 Also available at {{ slotProps.item.storeNames.join(', ') }}; quantity will be shared
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

interface ItemInCurrentStoreSuggestion {
  item: Item;
  type: 'item-in-current-store';
  value: string;
}

interface BrandNewItemSuggestion {
  type: 'brand-new-item';
  value: string;
}

interface ItemInOtherStoreSuggestion {
  item: Item;
  storeNames: Array<string>;
  type: 'item-in-other-store';
  value: string;
}

type ItemSuggestion =
  | BrandNewItemSuggestion
  | ItemInCurrentStoreSuggestion
  | ItemInOtherStoreSuggestion;

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
  const squishedQuery = queryString.trim().replace(/\s+/g, ' ');
  if (!squishedQuery) {
    callback([]);
    return;
  }

  const normalizedQuery = squishedQuery.toLowerCase();
  const currentStoreSuggestions: Array<ItemInCurrentStoreSuggestion> = helpers
    .sortByName(props.store.items)
    .filter((item) => item.name.toLowerCase().includes(normalizedQuery))
    .map((item) => ({
      item,
      type: 'item-in-current-store',
      value: item.name,
    }));
  const currentStoreItemIds = new Set(props.store.items.map((item) => item.id));
  const relatedStores =
    props.store.own_store ?
      groceriesStore.own_stores
    : groceriesStore.spouse_stores;
  const availableItems = new Map<number, Item>();
  for (const store of relatedStores) {
    for (const item of store.items) availableItems.set(item.id, item);
  }
  const otherStoreSuggestions: Array<ItemInOtherStoreSuggestion> = helpers
    .sortByName([...availableItems.values()])
    .filter(
      (item) =>
        !currentStoreItemIds.has(item.id) &&
        item.name.toLowerCase().includes(normalizedQuery),
    )
    .map((item) => ({
      item,
      storeNames: relatedStores
        .filter((store) => item.store_ids.includes(store.id))
        .map((store) => store.name),
      type: 'item-in-other-store',
      value: item.name,
    }));

  const matchingSuggestions = [
    ...currentStoreSuggestions,
    ...otherStoreSuggestions,
  ];
  const exactMatchExists = matchingSuggestions.some(
    ({ item }) => item.name.toLowerCase() === normalizedQuery,
  );
  const suggestions: Array<ItemSuggestion> = [];
  if (!exactMatchExists) {
    suggestions.push({ type: 'brand-new-item', value: queryString });
  }
  suggestions.push(...matchingSuggestions);

  callback(suggestions);
}

async function selectSuggestion(
  suggestion: AutocompleteDataItem,
): Promise<void> {
  const itemSuggestion = suggestion as ItemSuggestion;

  if (itemSuggestion.type === 'item-in-current-store') {
    formData.itemName = '';
    await blurAutocomplete();
    emit('itemTargeted', itemSuggestion.item);
    return;
  }

  const item = await groceriesStore.createItem({
    store: props.store,
    itemAttributes: {
      name:
        itemSuggestion.type === 'item-in-other-store' ?
          itemSuggestion.item.name
        : itemSuggestion.value,
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

<style lang="scss">
.grocery-item-suggestions {
  .el-autocomplete-suggestion__wrap {
    padding-block: 4px;
  }

  .el-autocomplete-suggestion li {
    position: relative;
    padding-block: 7px;
    line-height: 1.35;
    white-space: normal;

    & + li::before {
      content: '';
      position: absolute;
      top: 0;
      right: 20px;
      left: 20px;
      border-top: 1px solid var(--el-border-color-lighter);
    }
  }
}
</style>

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
