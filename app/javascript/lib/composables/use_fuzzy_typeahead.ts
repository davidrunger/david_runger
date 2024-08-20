import Fuse from 'fuse.js';
import { map } from 'lodash-es';
import { computed, ComputedRef, ref, Ref, watch } from 'vue';

export function useFuzzyTypeahead<T extends object>({
  searchables,
  query,
  propertyToSearch,
  maxMatches,
}: {
  searchables: Array<T>;
  query: Ref<string>;
  propertyToSearch: keyof T & string;
  maxMatches: number;
}) {
  const highlightedIndex = ref(0);
  const fuse = computed(() => {
    return new Fuse(searchables, { keys: [propertyToSearch] });
  });

  const rankedMatches: ComputedRef<Array<T>> = computed(() => {
    if (query.value === '') {
      return searchables;
    } else {
      return map(fuse.value.search(query.value), 'item');
    }
  });

  const topRankedMatches: ComputedRef<Array<T>> = computed(() =>
    rankedMatches.value.slice(0, maxMatches),
  );

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
    topRankedMatches,
  };
}
