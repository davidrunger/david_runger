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

  describe('pullStoreData', () => {
    it('adds a store and its items returned after the initial load', async () => {
      const newItem: Item = {
        id: 2,
        name: 'Pain reliever',
        needed: 1,
        store_id: 2,
      };
      const newStore: Store = {
        ...storeData,
        id: 2,
        items: [newItem],
        name: 'Pharmacy',
        own_store: false,
      };
      vi.mocked(http.get).mockResolvedValueOnce({
        own_stores: [],
        spouse_stores: [newStore],
      });

      await groceriesStore.pullStoreData();

      expect(groceriesStore.spouse_stores).toEqual([newStore]);
      expect(groceriesStore.spouse_stores[0].items).toEqual([newItem]);
    });

    it('adds a new item while updating existing records in place', async () => {
      const existingStore = groceriesStore.own_stores[0];
      const existingItem = existingStore.items[0];
      existingStore.viewed_at = '2026-08-28T12:00:00.000Z';
      const newItem: Item = {
        id: 2,
        name: 'Bananas',
        needed: 0,
        store_id: existingStore.id,
      };
      vi.mocked(http.get).mockResolvedValueOnce({
        own_stores: [
          {
            ...existingStore,
            items: [{ ...existingItem, name: 'Pears' }, newItem],
            name: 'Supermarket',
            viewed_at: '2026-08-28T13:00:00.000Z',
          },
        ],
        spouse_stores: [],
      });

      await groceriesStore.pullStoreData();

      expect(groceriesStore.own_stores[0]).toBe(existingStore);
      expect(existingStore).toMatchObject({
        name: 'Supermarket',
        viewed_at: '2026-08-28T12:00:00.000Z',
      });
      expect(existingStore.items[0]).toBe(existingItem);
      expect(existingStore.items).toEqual([
        { ...itemData, name: 'Pears' },
        newItem,
      ]);
    });
  });
});
