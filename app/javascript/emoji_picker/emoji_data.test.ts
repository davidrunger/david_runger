import { ref } from 'vue';

import { useFuzzyTypeahead } from '@/lib/composables/useFuzzyTypeahead';

import {
  boosts,
  emojiData,
  emojiDataLoading,
  loadEmojiData,
} from './emoji_data';

const emojiLibModule = Promise.withResolvers<{
  default: Record<string, Array<string>>;
}>();

vi.mock('emojilib', () => emojiLibModule.promise);

test('keeps matches empty until all emoji data finishes loading', async () => {
  boosts.value = [{ boostedName: 'favorite', symbol: '💜' }];

  const query = ref('favorite');
  const { topRankedMatches } = useFuzzyTypeahead({
    searchables: emojiData,
    query,
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

  const loadingEmojiData = loadEmojiData();

  expect(emojiDataLoading.value).toBe(true);
  expect(topRankedMatches.value).toEqual([]);

  emojiLibModule.resolve({
    default: {
      '🟣': ['purple_circle'],
    },
  });
  await loadingEmojiData;

  expect(emojiDataLoading.value).toBe(false);
  expect(topRankedMatches.value).toEqual([
    {
      boostedName: 'favorite',
      symbol: '💜',
    },
  ]);
});
