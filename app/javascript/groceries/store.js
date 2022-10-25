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
    store.items.unshift(itemData);
  },

  createItem({ store, itemAttributes }) {
    this.incrementPendingRequests();
    return kyApi.
      post(Routes.api_store_items_path(store.id), { json: { item: itemAttributes } }).
      json().
      then(itemData => {
        itemData.newlyAdded = true;
        this.decrementPendingRequests();
        this.addItem({ store, itemData });

        setTimeout(() => { itemData.newlyAdded = false; }, 1000);
      });
  },

  createStore(newStoreName) {
    this.postingStore = true;
    const payload = {
      store: {
        name: newStoreName,
      },
    };

    return (
      kyApi.
        post(Routes.api_stores_path(), { json: payload }).json().
        then(newStoreData => {
          this.postingStore = false;
          this.stores.unshift(newStoreData);
        })
    );
  },

  decrementPendingRequests() {
    this.pendingRequests -= 1;
  },

  deleteItem({ item }) {
    const store = this.currentStore;

    this.incrementPendingRequests();
    kyApi.delete(
      Routes.api_item_path(item.id),
      { headers: { 'content-type': 'application/json' } },
    ).json().
      then(() => {
        this.decrementPendingRequests();
        store.items = store.items.filter(storeItem => storeItem !== item);
      });
  },

  deleteStore({ store: deletedStore }) {
    this.stores = this.stores.filter(store => store !== deletedStore);
    kyApi.delete(Routes.api_store_path(deletedStore.id));
  },

  incrementPendingRequests() {
    this.pendingRequests += 1;
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

  updateItem({ item, attributes }) {
    this.incrementPendingRequests();

    kyApi.
      patch(Routes.api_item_path(item.id), { json: { item: attributes } }).
      json().
      then(updatedItemData => {
        Object.assign(item, updatedItemData);
        this.decrementPendingRequests();
      });
  },

  updateStore({ store, attributes }) {
    kyApi.
      patch(Routes.api_store_path(store.id), { json: { store: attributes } }).
      json().
      then(updatedStoreData => { Object.assign(store, updatedStoreData); });
  },

  zeroItems({ items }) {
    items.forEach(item => { item.needed = 0; });

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
  currentStore() {
    if (!this.stores) return null;

    return (
      last(sortBy(filter([...this.stores, ...this.spouse_stores], 'viewed_at'), 'viewed_at')) ||
      this.stores[0]
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
    return helpers.sortByName(this.stores);
  },
};

export const useGroceriesStore = defineStore('groceries', {
  state,
  actions,
  getters,
});
