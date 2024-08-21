import EmojiLibData from 'emojilib';
import { flatMap, isEqual, remove } from 'lodash-es';
import { computed, reactive } from 'vue';

import {
  type Bootstrap,
  type EmojiData,
  type EmojiDataWithBoostedName,
  type EmojiDataWithName,
} from '@/emoji_picker/types';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';

const emojilibData: Array<EmojiDataWithName> = flatMap(
  EmojiLibData,
  (names, symbol) => {
    return names.map((name) => {
      return {
        symbol,
        name: name.replace(/_/g, ' '),
      };
    });
  },
);

const bootstrap = untypedBootstrap as Bootstrap;

export const boosts = reactive<Array<EmojiDataWithBoostedName>>(
  bootstrap.current_user?.emoji_boosts || [],
);

const possibleDuplicatesToRemoveFromEmojiData = boosts.map((boost) => ({
  symbol: boost.symbol,
  name: boost.boostedName,
}));

remove(emojilibData, (item) =>
  possibleDuplicatesToRemoveFromEmojiData.some((otherItem) =>
    isEqual(item, otherItem),
  ),
);

export const emojiData = computed<Array<EmojiData>>(() => [
  ...emojilibData,
  ...boosts,
]);
