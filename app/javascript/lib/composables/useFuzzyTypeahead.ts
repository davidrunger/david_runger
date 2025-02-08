import Fuse, { IFuseOptions } from 'fuse.js';
import { map } from 'lodash-es';
import { computed, ComputedRef, ref, Ref, watch } from 'vue';

export function useFuzzyTypeahead<T extends object>({
  searchables,
  query,
  maxMatches,
  fuseOptions,
}: {
  searchables: Ref<Array<T>>;
  query: Ref<string>;
  maxMatches?: number;
  fuseOptions: IFuseOptions<T>;
}) {
  const highlightedIndex = ref(0);
  const fuse = computed(() => {
    return new Fuse(searchables.value, fuseOptions);
  });

  const rankedMatches: ComputedRef<Array<T>> = computed(() => {
    if (query.value === '') {
      return searchables.value;
    } else {
      const searchResult = fuse.value.search(query.value);
      return map(searchResult, 'item');
    }
  });

  const topRankedMatches: ComputedRef<Array<T>> = computed(() => {
    if (maxMatches) {
      return rankedMatches.value.slice(0, maxMatches);
    } else {
      return rankedMatches.value;
    }
  });

  // reset highlightedLogIndex to 0 whenever the matched logs changes (e.g. the user types more)
  watch(topRankedMatches, () => {
    highlightedIndex.value = 0;
  });

  const highlightedSearchable = computed<T>(() => {
    return topRankedMatches.value[highlightedIndex.value];
  });

  function onArrowUp() {
    if (highlightedIndex.value > 0) {
      highlightedIndex.value--;
    } else {
      // wrap around from the top of the list to the bottom
      highlightedIndex.value = topRankedMatches.value.length - 1;
    }
  }

  function onArrowDown() {
    if (highlightedIndex.value < topRankedMatches.value.length - 1) {
      highlightedIndex.value++;
    } else {
      // wrap back around to the top of the list
      highlightedIndex.value = 0;
    }
  }

  return {
    highlightedSearchable,
    onArrowDown,
    onArrowUp,
    rankedMatches,
    topRankedMatches,
  };
}
