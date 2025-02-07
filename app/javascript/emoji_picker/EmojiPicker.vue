<template lang="pug">
.text-center
  h1 Emoji Picker

  form.my-6(@submit.prevent).text-2xl
    input.text-center(
      name="Search for an emoji"
      type='text'
      autofocus
      v-model='query'
    )

  ul.mx-auto.max-w-sm
    li.py-1(
      v-for='emojiData in topRankedMatches'
      :class='listItemClasses(emojiData)'
      @click='selectEmoji(emojiData)'
    )
      button
        span.align-middle.text-4xl {{ emojiData.symbol }}
        span.ml-1.align-middle.text-xl {{ emojiData.boostedName || emojiData.name }}

  BoostsForm(v-if='bootstrap.current_user')
  .flex.justify-center(v-else)
    .mt-8.max-w-sm
      b Tip:
      span.
        #[a(:href='new_user_session_path()')  log in] to customize
        which search keywords are associated with which emojis.
</template>

<script setup lang="ts">
import { refDebounced } from '@vueuse/core';
import { onBeforeUnmount, onMounted, ref } from 'vue';
import { POSITION } from 'vue-toastification';

import BoostsForm from '@/emoji_picker/components/BoostsForm.vue';
import CopiedEmojiToast from '@/emoji_picker/components/CopiedEmojiToast.vue';
import { emojiData } from '@/emoji_picker/emoji_data';
import { type Bootstrap } from '@/emoji_picker/types';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { useFuzzyTypeahead } from '@/lib/composables/use_fuzzy_typeahead';
import { vueToast } from '@/lib/vue_toasts';
import { new_user_session_path } from '@/rails_assets/routes';
import type { EmojiData } from '@/types';

const bootstrap = untypedBootstrap as Bootstrap;

const query = ref('');
const queryDebounced = refDebounced(query, 60, { maxWait: 180 });
const { highlightedSearchable, onArrowDown, onArrowUp, topRankedMatches } =
  useFuzzyTypeahead({
    searchables: emojiData,
    query: queryDebounced,
    maxMatches: 10,
    fuseOptions: {
      keys: [
        'name',
        {
          name: 'boostedName',
          weight: 1.5,
        },
      ],
      threshold: 0.35,
      useExtendedSearch: true,
    },
  });

function handleKeydown(event: KeyboardEvent) {
  switch (event.key) {
    case 'Enter':
      selectEmoji(highlightedSearchable.value);
      break;
    case 'ArrowUp':
      onArrowUp();
      break;
    case 'ArrowDown':
      onArrowDown();
      break;
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
});

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown);
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
      position: POSITION.TOP_CENTER,
    },
  );
}
</script>
