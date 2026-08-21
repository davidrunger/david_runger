import { createPinia, setActivePinia } from 'pinia';

import type { Item } from '@/groceries/types';
import { http } from '@/lib/http';
import type { Store } from '@/types';

vi.mock('@/lib/http', () => ({
  http: {
    delete: vi.fn(),
    get: vi.fn(),
    patch: vi.fn(),
    post: vi.fn(),
  },
}));

const storeData: Store = {
  id: 1,
  items: [],
  name: 'Groceries',
  notes: null,
  own_store: true,
  private: false,
  viewed_at: null,
};

const itemData: Item = {
  id: 1,
  name: 'Apples',
  needed: 1,
  store_id: storeData.id,
};

describe('useGroceriesStore', () => {
  let useGroceriesStore: typeof import('./store').useGroceriesStore;
  let groceriesStore: ReturnType<typeof useGroceriesStore>;
  let item: Item;

  beforeAll(async () => {
    window.davidrunger = { bootstrap: {}, env: 'test' };
    ({ useGroceriesStore } = await import('./store'));
  });

  beforeEach(() => {
    vi.resetAllMocks();
    setActivePinia(createPinia());
    groceriesStore = useGroceriesStore();
    item = { ...itemData };
    groceriesStore.own_stores = [{ ...storeData, items: [item] }];
    groceriesStore.spouse_stores = [];
  });

  it('clears the posting state when creating a store fails', async () => {
    const error = new Error('Network failure');
    vi.mocked(http.post).mockRejectedValueOnce(error);

    await expect(groceriesStore.createStore('New store')).rejects.toThrow(
      error,
    );

    expect(groceriesStore.postingStore).toBe(false);
  });

  it.each([
    [
      'creating an item',
      () =>
        groceriesStore.createItem({
          store: groceriesStore.own_stores[0],
          itemAttributes: { name: 'Bananas' },
        }),
    ],
    ['deleting an item', () => groceriesStore.destroyItem({ item })],
    [
      'updating an item',
      () =>
        groceriesStore.updateItem({
          item,
          attributes: { name: 'Pears' },
        }),
    ],
  ])('clears pending request state when %s fails', async (_action, action) => {
    const error = new Error('Network failure');
    vi.mocked(http.delete).mockRejectedValueOnce(error);
    vi.mocked(http.patch).mockRejectedValueOnce(error);
    vi.mocked(http.post).mockRejectedValueOnce(error);

    await expect(action()).rejects.toThrow(error);

    expect(groceriesStore.pendingRequests).toBe(0);
  });
});
