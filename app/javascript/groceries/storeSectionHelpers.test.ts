import type { Store, StoreSectionScheme } from '@/types';

import { matchingSchemeFor, normalizedName } from './storeSectionHelpers';

const store: Store = {
  id: 1,
  item_section_assignments: [],
  items: [],
  name: 'Costco',
  notes: null,
  own_store: true,
  private: false,
  section_configuration: null,
  viewed_at: null,
};

const storeSectionSchemes: Array<StoreSectionScheme> = [
  { id: 1, name: 'costco', store_sections: [] },
  { id: 2, name: "Trader Joe's", store_sections: [] },
];

describe('matchingSchemeFor', () => {
  it('matches a layout name without regard to letter case', () => {
    expect(matchingSchemeFor(store, storeSectionSchemes)).toBe(
      storeSectionSchemes[0],
    );
  });

  it('returns undefined without a matching layout', () => {
    const storeWithoutLayout = { ...store, name: 'Target' };

    expect(matchingSchemeFor(storeWithoutLayout, storeSectionSchemes)).toBe(
      undefined,
    );
  });
});

describe('normalizedName', () => {
  it('trims leading and trailing whitespace and collapses internal whitespace', () => {
    expect(normalizedName('  Frozen\n  vegetables  ')).toBe(
      'Frozen vegetables',
    );
  });
});
