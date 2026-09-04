import { fireEvent, render, screen } from '@testing-library/vue';
import { createPinia } from 'pinia';

import { useGroceriesStore } from '@/groceries/store';
import type { Store } from '@/types';

import CheckInStoreList from './CheckInStoreList.vue';

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

describe('CheckInStoreList', () => {
  it('toggles a store when its colored card is clicked', async () => {
    const pinia = createPinia();
    const groceriesStore = useGroceriesStore(pinia);

    render(CheckInStoreList, {
      global: { plugins: [pinia] },
      props: { stores: [store] },
    });

    const storeCard = screen.getByText(store.name).closest('label');
    expect(storeCard?.classList.contains('check-in-store')).toBe(true);

    await fireEvent.click(storeCard as HTMLLabelElement);
    expect(groceriesStore.checkInStores).toEqual([store]);

    await fireEvent.click(storeCard as HTMLLabelElement);
    expect(groceriesStore.checkInStores).toEqual([]);
  });
});
