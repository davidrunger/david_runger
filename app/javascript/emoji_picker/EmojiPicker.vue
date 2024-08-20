<template lang="pug">
.text-center
  h1 Emojis

  form.my-6(@submit.prevent).text-2xl
    input.text-center(
      type='text'
      autofocus
      v-model='query'
      @keydown.up='onArrowUp'
      @keydown.down='onArrowDown'
      @keydown.enter='selectEmoji(highlightedSearchable)'
    )

  ul.mx-auto.max-w-sm
    li.py-1(
      v-for='emojiData in topRankedMatches'
      :class='listItemClasses(emojiData)'
      @click='selectEmoji(emojiData)'
    )
      button
        span.align-middle.text-4xl {{ emojiData.symbol }}
        span.ml-1.align-middle.text-xl {{ emojiData.name }}
</template>

<script setup lang="ts">
import { refDebounced } from '@vueuse/core';
import EmojiLibData from 'emojilib';
import { flatMap } from 'lodash-es';
import { ref } from 'vue';

import CopiedEmojiToast from '@/emoji_picker/components/CopiedEmojiToast.vue';
import { useFuzzyTypeahead } from '@/lib/composables/use_fuzzy_typeahead';
import { vueToast } from '@/lib/vue_toasts';

interface EmojiData {
  symbol: string;
  name: string;
}

const EMOJI_DATA: Array<EmojiData> = flatMap(EmojiLibData, (names, symbol) => {
  return names.map((name) => {
    return {
      symbol,
      name: name.replace(/_/g, ' '),
    };
  });
});

const query = ref('');
const queryDebounced = refDebounced(query, 60, { maxWait: 180 });
const { highlightedSearchable, onArrowDown, onArrowUp, topRankedMatches } =
  useFuzzyTypeahead({
    searchables: EMOJI_DATA,
    query: queryDebounced,
    propertyToSearch: 'name',
    maxMatches: 10,
  });

function listItemClasses(emojiData: EmojiData) {
  const isSelected = emojiData === highlightedSearchable.value;

  return [
    'cursor-pointer',
    'hover:bg-sky-100',
    { 'font-bold bg-sky-200': isSelected },
  ];
}

function selectEmoji(emojiData: EmojiData) {
  const symbol = emojiData.symbol;

  navigator.clipboard.writeText(symbol);
  vueToast(
    {
      component: CopiedEmojiToast,
      props: {
        symbol,
      },
    },
    {
      icon: false,
    },
  );
}
</script>
