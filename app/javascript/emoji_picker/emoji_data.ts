import { watchDebounced } from '@vueuse/core';
import EmojiLibData from 'emojilib';
import { flatMap, isEqual } from 'lodash-es';
import { computed, ref } from 'vue';

import { type Bootstrap } from '@/emoji_picker/types';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import type { EmojiData, EmojiDataWithBoostedName } from '@/types';

const originalEmojilibData = flatMap(EmojiLibData, (names, symbol) => {
  return names.map((name) => {
    return {
      symbol,
      name: name.replace(/_/g, ' '),
    };
  });
});

const emojilibData = ref(originalEmojilibData);

const bootstrap = untypedBootstrap as Bootstrap;

export const boosts = ref<Array<EmojiDataWithBoostedName>>(
  bootstrap.current_user?.emoji_boosts || [],
);

watchDebounced(
  boosts,
  () => {
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
  },
  { debounce: 800, immediate: true },
);

export const emojiData = computed<Array<EmojiData>>(() => [
  ...emojilibData.value,
  ...boosts.value,
]);
