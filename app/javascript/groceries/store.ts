import { defineStore } from 'pinia';
import { filter, get, last, pick, sortBy } from 'lodash-es';
import { kyApi } from '@/shared/ky';
import { emit } from '@/lib/event_bus';
import { Bootstrap, Item, Store } from '@/groceries/types';
import * as RoutesType from '@/rails_assets/routes';

declare var Routes: typeof RoutesType;

interface State {
  own_stores: Array<Store>
  spouse_stores: Array<Store>
  collectingDebounces: boolean
  pendingRequests: number
  postingStore: boolean
  checkInStores: Store[]
  skippedItems: Item[]
}

interface Identifiable {
  id: number
}

interface Nameable {
  name: string
}

interface StoreAttributes {
  name?: string
  notes?: string
  private?: boolean
}

export const helpers = {
  getById<T>(collection: Array<Identifiable & T>, id: number): T | undefined {
    return collection.find(item => item.id === id);
  },

  sortByName<T>(objects: Array<Nameable & T>): Array<T> {
    return sortBy(objects, object => object.name.toLowerCase());
  },
};

export const useGroceriesStore = defineStore('groceries', {
  state: (): State => ({
    own_stores: (window.davidrunger.bootstrap as Bootstrap).own_stores,
    spouse_stores: (window.davidrunger.bootstrap as Bootstrap).spouse_stores,
    collectingDebounces: false,
    pendingRequests: 0,
    postingStore: false,
    checkInStores: [],
    skippedItems: [],
  }),

  actions: {
    addCheckInStore({ store }: { store: Store }) {
      if (this.checkInStores.includes(store)) return;

      this.checkInStores = [...this.checkInStores, store];
    },

    addItem({ store, itemData }: { store?: Store, itemData: Item }) {
      store = store || helpers.getById(this.allStores, itemData.store_id);

      // don't add item to store if it's already there
      if (helpers.getById(store!.items, itemData.id)) return;

      itemData.newlyAdded = true;
      store!.items.unshift(itemData);
      setTimeout(() => { itemData.newlyAdded = false; }, 1000);
    },

    async createItem({ store, itemAttributes }: { store: Store, itemAttributes: { name: string } }) {
      this.incrementPendingRequests();

      const itemData: Item = await kyApi.post(
        Routes.api_store_items_path(store.id),
        { json: { item: itemAttributes } },
      ).json();

      this.decrementPendingRequests();
      this.addItem({ store, itemData });
    },

    async createStore(newStoreName: string) {
      this.postingStore = true;
      const payload = {
        store: {
          name: newStoreName,
        },
      };

      const newStoreData: Store =
        await kyApi.post(
          Routes.api_stores_path(),
          { json: payload },
        ).json();

      this.postingStore = false;
      this.own_stores.unshift(newStoreData);
    },

    decrementPendingRequests() {
      this.pendingRequests -= 1;
    },

    deleteItem({ item }: { item: Item }) {
      const store = helpers.getById(this.allStores, item.store_id);
      store!.items = store!.items.filter(storeItem => storeItem.id !== item.id);
    },

    async destroyItem({ item }: { item: Item }) {
      this.incrementPendingRequests();
      await kyApi.delete(
        Routes.api_item_path(item.id),
        { headers: { 'content-type': 'application/json' } },
      );

      this.decrementPendingRequests();
      this.deleteItem({ item });
    },

    deleteStore({ store: deletedStore }: { store: Store }) {
      this.own_stores = this.own_stores.filter(store => store !== deletedStore);
      kyApi.delete(Routes.api_store_path(deletedStore.id));
    },

    async pullStoreData() {
      const addOrUpdateStores = (storeData: Array<Store>, existingStores: Array<Store>) => {
        for (const storeDatum of storeData) {
          const existingStore = helpers.getById(existingStores, storeDatum.id);
          storeDatum.viewed_at = get(existingStore, 'viewed_at') ?? storeDatum.viewed_at;
          if (existingStore) {
            const items = [];
            for (const itemDatum of storeDatum.items) {
              const existingItem = helpers.getById(existingStore.items, itemDatum.id);
              if (existingItem) {
                Object.assign(existingItem, itemDatum);
                items.push(existingItem);
              } else {
                items.push(itemDatum);
              }
            }
            storeDatum.items = items;
            Object.assign(existingStore, storeDatum);
          } else {
            existingStores.push(storeDatum);
          }
        }
      };

      interface StoresResponse {
        own_stores: Array<Store>
        spouse_stores: Array<Store>
      }

      const storesResponse: StoresResponse = await kyApi.get(Routes.api_stores_path()).json()
      addOrUpdateStores(storesResponse.own_stores, this.own_stores);
      addOrUpdateStores(storesResponse.spouse_stores, this.spouse_stores);
    },

    incrementPendingRequests() {
      this.pendingRequests += 1;
    },

    modifyItem({ item, attributes }: { item?: Item, attributes: Item }) {
      if (!item) {
        const store = helpers.getById(this.allStores, attributes.store_id);
        item = helpers.getById(store!.items, attributes.id);
      }
      Object.assign(item!, attributes);
    },

    selectStore({ store }: { store: Store }) {
      // update the store's viewed_at time so that it will become the `currentStore`
      store.viewed_at = (new Date()).toISOString();

      // emit event so sidebar can collapse if on mobile
      emit('groceries:store-selected');

      if (store.own_store) {
        kyApi.patch(
          Routes.api_store_path(store.id),
          { json: { store: pick(store, ['viewed_at']) } },
        );
      }
    },

    setCollectingDebounces({ value }: { value: boolean }) {
      this.collectingDebounces = value;
    },

    skipItem({ item }: { item: Item }) {
      if (this.skippedItems.includes(item)) return;

      this.skippedItems = [...this.skippedItems, item];
    },

    unskipItem({ item: itemToUnskip }: { item: Item }) {
      this.skippedItems = this.skippedItems.filter(item => item.id !== itemToUnskip.id);
    },

    async updateItem({ item, attributes }: { item: Item, attributes: { name: string } }) {
      this.incrementPendingRequests();

      const updatedItemData: Item =
        await kyApi.patch(
          Routes.api_item_path(item.id),
          { json: { item: attributes } },
        ).json();

      this.decrementPendingRequests();

      if (!this.debouncingOrWaitingOnNetwork) {
        this.modifyItem({ item, attributes: updatedItemData });
      }
    },

    async updateStore({ store, attributes }: { store: Store, attributes: StoreAttributes }) {
      const updatedStoreData =
        await kyApi.patch(
          Routes.api_store_path(store.id),
          { json: { store: attributes } },
        ).json();

      Object.assign(store, updatedStoreData);
    },

    async zeroItems({ items }: { items: Array<Item> }) {
      await kyApi.post(
        Routes.api_items_bulk_updates_path(),
        {
          json: {
            bulk_update: {
              item_ids: items.map(item => item.id),
              attributes_change: { needed: 0 },
            },
          },
        },
      );

      for (const item of items) item.needed = 0;
    },
  },

  getters: {
    allStores(): Array<Store> {
      return [...this.own_stores, ...this.spouse_stores];
    },

    currentStore(): Store | null {
      if (!this.own_stores) return null;

      return (
        last(sortBy(filter(this.allStores, 'viewed_at'), 'viewed_at')) ||
        this.own_stores[0]
      );
    },

    debouncingOrWaitingOnNetwork(): boolean {
      return this.collectingDebounces || (this.pendingRequests > 0);
    },

    neededCheckInItems(): Array<Item> {
      return helpers.sortByName(
        this.checkInStores.
          map(store => (
            store.items.filter(item => (
              item.needed > 0 && !this.skippedItems.includes(item)
            ))
          )).flat(),
      );
    },

    sortedSpouseStores(): Array<Store> {
      return helpers.sortByName(this.spouse_stores);
    },

    sortedStores(): Array<Store> {
      return helpers.sortByName(this.own_stores);
    },
  },
});
