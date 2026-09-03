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
  section_configuration: null,
  item_section_assignments: [],
  viewed_at: null,
};

const itemData: Item = {
  id: 1,
  name: 'Apples',
  needed: 1,
  store_ids: [storeData.id],
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
    item = { ...itemData, store_ids: [...itemData.store_ids] };
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

  it('uses one item object in each store where it is available', () => {
    const otherStore = {
      ...storeData,
      id: 2,
      items: [],
      name: 'Supermarket',
    };
    groceriesStore.own_stores.push(otherStore);

    const sharedItem = groceriesStore.addItem({
      itemData: {
        ...item,
        needed: 2,
        store_ids: [storeData.id, otherStore.id],
      },
    });

    expect(groceriesStore.own_stores[0].items).toEqual([sharedItem]);
    expect(groceriesStore.own_stores[1].items).toEqual([sharedItem]);
    expect(groceriesStore.own_stores[1].items[0]).toBe(
      groceriesStore.own_stores[0].items[0],
    );
    expect(sharedItem.needed).toBe(2);
  });

  it('lists a shared item once during a multi-store check-in', () => {
    const otherStore = {
      ...storeData,
      id: 2,
      items: [item],
      name: 'Supermarket',
    };
    item.store_ids = [storeData.id, otherStore.id];
    groceriesStore.own_stores.push(otherStore);
    groceriesStore.checkInStores = groceriesStore.own_stores;

    expect(groceriesStore.neededCheckInItems).toEqual([item]);
  });

  it('removes a deleted store from its shared items', () => {
    const deletedStore = groceriesStore.own_stores[0];
    const sharedItem = deletedStore.items[0];
    const otherStore = {
      ...storeData,
      id: 2,
      items: [sharedItem],
      name: 'Supermarket',
    };
    sharedItem.store_ids = [deletedStore.id, otherStore.id];
    groceriesStore.own_stores.push(otherStore);

    groceriesStore.deleteStore({ store: deletedStore });

    expect(groceriesStore.own_stores).toEqual([otherStore]);
    expect(sharedItem.store_ids).toEqual([otherStore.id]);
  });

  describe('pullStoreData', () => {
    it('adds a store and its items returned after the initial load', async () => {
      const newItem: Item = {
        id: 2,
        name: 'Pain reliever',
        needed: 1,
        store_ids: [2],
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

    it('removes own and spouse stores absent from the response', async () => {
      const retainedOwnStore = groceriesStore.own_stores[0];
      const staleOwnStore: Store = {
        ...storeData,
        id: 2,
        name: 'Pharmacy',
      };
      const retainedSpouseStore: Store = {
        ...storeData,
        id: 3,
        name: 'Supermarket',
        own_store: false,
      };
      const staleSpouseStore: Store = {
        ...storeData,
        id: 4,
        name: 'Warehouse club',
        own_store: false,
      };
      groceriesStore.own_stores.push(staleOwnStore);
      groceriesStore.spouse_stores = [retainedSpouseStore, staleSpouseStore];
      vi.mocked(http.get).mockResolvedValueOnce({
        own_stores: [
          { ...retainedOwnStore, items: [...retainedOwnStore.items] },
        ],
        spouse_stores: [
          { ...retainedSpouseStore, items: [...retainedSpouseStore.items] },
        ],
      });

      await groceriesStore.pullStoreData();

      expect(groceriesStore.own_stores).toEqual([retainedOwnStore]);
      expect(groceriesStore.spouse_stores).toEqual([retainedSpouseStore]);
    });

    it('adds a new item while updating existing records in place', async () => {
      const existingStore = groceriesStore.own_stores[0];
      const existingItem = existingStore.items[0];
      existingStore.viewed_at = '2026-08-28T12:00:00.000Z';
      const newItem: Item = {
        id: 2,
        name: 'Bananas',
        needed: 0,
        store_ids: [existingStore.id],
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
