import { defineStore } from 'pinia';
import { filter, last, pick, sortBy } from 'lodash-es';
import { kyApi } from '@/shared/ky';
import { emit } from '@/lib/event_bus';

const state = () => ({
  ...window.davidrunger.bootstrap,
  collectingDebounces: false,
  pendingRequests: 0,
  postingStore: false,
  checkInStores: [],
  skippedItems: [],
});

export const helpers = {
  getById(collection, id) {
    return collection.find(item => item.id === id);
  },

  sortByName(objects) {
    return sortBy(objects, object => object.name.toLowerCase());
  },
};

const actions = {
  addCheckInStore({ store }) {
    if (this.checkInStores.includes(store)) return;

    this.checkInStores = [...this.checkInStores, store];
  },

  addItem({ store, itemData }) {
    store = store || helpers.getById(this.allStores, itemData.store_id);

    // don't add item to store if it's already there
    if (helpers.getById(store.items, itemData.id)) return;

    itemData.newlyAdded = true;
    store.items.unshift(itemData);
    setTimeout(() => { itemData.newlyAdded = false; }, 1000);
  },

  async createItem({ store, itemAttributes }) {
    this.incrementPendingRequests();

    const itemData = await kyApi.post(
      Routes.api_store_items_path(store.id),
      { json: { item: itemAttributes } },
    ).json();

    this.decrementPendingRequests();
    this.addItem({ store, itemData });
  },

  async createStore(newStoreName) {
    this.postingStore = true;
    const payload = {
      store: {
        name: newStoreName,
      },
    };

    const newStoreData =
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

  deleteItem({ item }) {
    const store = helpers.getById(this.allStores, item.store_id);
    store.items = store.items.filter(storeItem => storeItem.id !== item.id);
  },

  async destroyItem({ item }) {
    this.incrementPendingRequests();
    await kyApi.delete(
      Routes.api_item_path(item.id),
      { headers: { 'content-type': 'application/json' } },
    );

    this.decrementPendingRequests();
    this.deleteItem({ item });
  },

  deleteStore({ store: deletedStore }) {
    this.own_stores = this.own_stores.filter(store => store !== deletedStore);
    kyApi.delete(Routes.api_store_path(deletedStore.id));
  },

  incrementPendingRequests() {
    this.pendingRequests += 1;
  },

  modifyItem({ item, attributes }) {
    if (!item) {
      const store = helpers.getById(this.allStores, attributes.store_id);
      item = helpers.getById(store.items, attributes.id);
    }
    Object.assign(item, attributes);
  },

  selectStore({ store }) {
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

  setCollectingDebounces({ value }) {
    this.collectingDebounces = value;
  },

  skipItem({ item }) {
    if (this.skippedItems.includes(item)) return;

    this.skippedItems = [...this.skippedItems, item];
  },

  unskipItem({ item: itemToUnskip }) {
    this.skippedItems = this.skippedItems.filter(item => item.id !== itemToUnskip.id);
  },

  async updateItem({ item, attributes }) {
    this.incrementPendingRequests();

    const updatedItemData =
      await kyApi.patch(
        Routes.api_item_path(item.id),
        { json: { item: attributes } },
      ).json();

    this.modifyItem({ item, attributes: updatedItemData });
    this.decrementPendingRequests();
  },

  async updateStore({ store, attributes }) {
    const updatedStoreData =
      await kyApi.patch(
        Routes.api_store_path(store.id),
        { json: { store: attributes } },
      ).json();

    Object.assign(store, updatedStoreData);
  },

  zeroItems({ items }) {
    for (const item of items) item.needed = 0;

    kyApi.post(
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
  },
};

const getters = {
  allStores() {
    return [...this.own_stores, ...this.spouse_stores];
  },

  currentStore() {
    if (!this.own_stores) return null;

    return (
      last(sortBy(filter(this.allStores, 'viewed_at'), 'viewed_at')) ||
      this.own_stores[0]
    );
  },

  debouncingOrWaitingOnNetwork() {
    return this.collectingDebounces || (this.pendingRequests > 0);
  },

  neededCheckInItems() {
    return helpers.sortByName(
      this.checkInStores.
        map(store => (
          store.items.filter(item => (
            item.needed > 0 && !this.skippedItems.includes(item)
          ))
        )).flat(),
    );
  },

  sortedSpouseStores() {
    return helpers.sortByName(this.spouse_stores);
  },

  sortedStores() {
    return helpers.sortByName(this.own_stores);
  },
};

export const useGroceriesStore = defineStore('groceries', {
  state,
  actions,
  getters,
});
