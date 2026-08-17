<template lang="pug">
form.flex(
  v-if="store.own_store"
  @submit.prevent
)
  ElAutocomplete.item-name-input.max-w-60(
    v-model="formData.newItemName"
    :debounce="0"
    :fetch-suggestions="itemSuggestions"
    :trigger-on-focus="false"
    fit-input-width
    name="newItemName"
    placeholder="Add an item"
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
  type AutocompleteFetchSuggestionsCallback,
} from 'element-plus';
import { nextTick, reactive } from 'vue';
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

const formData = reactive({
  newItemName: '',
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

async function selectSuggestion(suggestion: ItemSuggestion): Promise<void> {
  if (suggestion.type === 'existing') {
    formData.newItemName = '';
    await nextTick();
    document
      .getElementById(`grocery-item-${suggestion.item.id}`)
      ?.scrollIntoView({
        behavior: 'smooth',
        block: 'center',
      });
    return;
  }

  const success = await groceriesStore.createItem({
    store: props.store,
    itemAttributes: {
      name: suggestion.value,
    },
  });

  if (success) {
    formData.newItemName = '';
  }
}
</script>
