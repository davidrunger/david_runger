import { watchDebounced } from '@vueuse/core';
import { isEqual } from 'es-toolkit';
import { computed, ref } from 'vue';

import { bootstrap } from '@/emoji_picker/bootstrap';
import type {
  EmojiData,
  EmojiDataWithBoostedName,
  EmojiDataWithName,
} from '@/types';

let originalEmojilibData: Array<EmojiDataWithName> = [];
const emojilibData = ref<Array<EmojiDataWithName>>([]);

export const emojiDataLoading = ref(true);

export const boosts = ref<Array<EmojiDataWithBoostedName>>(
  bootstrap.current_user?.emoji_boosts || [],
);

function updateEmojilibData() {
  const possibleDuplicatesToRemoveFromEmojiData = boosts.value.map((boost) => ({
    symbol: boost.symbol,
    name: boost.boostedName,
  }));

  emojilibData.value = originalEmojilibData.filter(
    (item) =>
      !possibleDuplicatesToRemoveFromEmojiData.some((possibleDuplicate) =>
        isEqual(item, possibleDuplicate),
      ),
  );
}

watchDebounced(boosts.value, updateEmojilibData, {
  debounce: 800,
  immediate: true,
});

export const emojiData = computed<Array<EmojiData>>(() => {
  if (emojiDataLoading.value) {
    return [];
  }

  return [...emojilibData.value, ...boosts.value];
});

export async function loadEmojiData() {
  const { default: emojiLibData } = await import('emojilib');

  originalEmojilibData = Object.entries(emojiLibData).flatMap(
    ([symbol, names]) =>
      names.map((name) => ({
        symbol,
        name: name.replace(/_/g, ' '),
      })),
  );
  updateEmojilibData();
  emojiDataLoading.value = false;
}
