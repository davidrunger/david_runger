import EmojiLibData from 'emojilib';
import { flatMap, isEqual, remove } from 'lodash-es';

import {
  EmojiData,
  EmojiDataWithBoostedName,
  EmojiDataWithName,
} from '@/emoji_picker/types';

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

const boosts: Array<EmojiDataWithBoostedName> = [
  { symbol: '🙂', boostedName: 'smile' },
];

const possibleDuplicatesToRemoveFromEmojiData = boosts.map((boost) => ({
  symbol: boost.symbol,
  name: boost.boostedName,
}));

remove(emojilibData, (item) =>
  possibleDuplicatesToRemoveFromEmojiData.some((otherItem) =>
    isEqual(item, otherItem),
  ),
);

export const EMOJI_DATA: Array<EmojiData> = [...emojilibData, ...boosts];
