<template lang="pug">
.text-center
  h1 Emoji Picker

  form.my-6.text-2xl(@submit.prevent)
    input.text-center(
      name="Search for an emoji"
      type="text"
      autofocus
      autocomplete="off"
      v-model="query"
    )

  ul.mx-auto.max-w-sm
    li.py-1(
      v-for="emojiDatum in topRankedMatches"
      :class="listItemClasses(emojiDatum)"
      @click="selectEmoji(emojiDatum)"
    )
      button
        span.align-middle.text-4xl {{ emojiDatum.symbol }}
        span.ml-1.align-middle.text-xl {{ emojiDatum.boostedName || emojiDatum.name }}

  BoostsForm(v-if="bootstrap.current_user")
  .flex.justify-center(v-else)
    .mt-8.max-w-sm #[GoogleLoginButton(:origin="googleLoginOrigin")] to customize which search keywords are associated with which emojis.
</template>

<script setup lang="ts">
import { refDebounced } from '@vueuse/core';
import { onBeforeUnmount, onMounted, ref } from 'vue';
import { POSITION } from 'vue-toastification';

import GoogleLoginButton from '@/components/GoogleLoginButton.vue';
import BoostsForm from '@/emoji_picker/components/BoostsForm.vue';
import CopiedEmojiToast from '@/emoji_picker/components/CopiedEmojiToast.vue';
import { emojiData } from '@/emoji_picker/emoji_data';
import { type Bootstrap } from '@/emoji_picker/types';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { useFuzzyTypeahead } from '@/lib/composables/useFuzzyTypeahead';
import { vueToast } from '@/lib/vue_toasts';
import type { EmojiData } from '@/types';

const bootstrap = untypedBootstrap as Bootstrap;

const query = ref('');
const queryDebounced = refDebounced(query, 60, { maxWait: 180 });
const { highlightedSearchable, onArrowDown, onArrowUp, topRankedMatches } =
  useFuzzyTypeahead({
    searchables: emojiData,
    query: queryDebounced,
    maxMatches: 80,
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

const googleLoginOrigin = window.location.href;

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
