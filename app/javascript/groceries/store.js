import { filter, last, pick, sortBy } from 'lodash-es';
import { kyApi } from '@/shared/ky';

import {
  getters as modalGetters,
  mutations as modalMutations,
  state as modalState,
} from '@/shared/modal_store';

const mutations = {
  ...modalMutations,

  addItem(state, { store, itemData }) {
    store.items.unshift(itemData);
  },

  deleteItem(state, { item, store }) {
    store.items = store.items.filter(storeItem => storeItem !== item);
  },

  deleteStore(state, { store: deletedStore }) {
    state.stores = state.stores.filter(store => store !== deletedStore);
  },

  decrementPendingRequests(state) {
    state.pendingRequests -= 1;
  },

  incrementPendingRequests(state) {
    state.pendingRequests += 1;
  },

  setCollectingDebounces(state, { value }) {
    state.collectingDebounces = value;
  },

  updateItem(_state, { item, updatedItemData }) {
    Object.assign(item, updatedItemData);
  },
};

const actions = {
  createItem({ commit }, { store, itemAttributes }) {
    kyApi.
      post(Routes.api_store_items_path(store.id), { json: { item: itemAttributes } }).
      json().
      then(itemData => {
        commit('decrementPendingRequests');
        commit('addItem', { store, itemData });
      });
  },

  deleteItem({ commit, getters }, { item }) {
    kyApi.delete(Routes.api_item_path(item.id));
    commit('deleteItem', { item, store: getters.currentStore });
  },

  deleteStore({ commit }, { store }) {
    kyApi.delete(Routes.api_store_path(store.id));
    commit('deleteStore', { store });
  },

  selectStore(_context, { store }) {
    // update the store's viewed_at time, bc. this is actually how we determine the selected store
    store.viewed_at = (new Date()).toISOString();
    kyApi.patch(Routes.api_store_path(store.id), { json: { store: pick(store, ['viewed_at']) } });
  },

  updateItem({ commit }, { item, attributes }) {
    kyApi.
      patch(Routes.api_item_path(item.id), { json: { item: attributes } }).
      json().
      then(updatedItemData => {
        commit(
          'updateItem',
          { item, updatedItemData },
        );
      });
  },

  updateStore(_context, { id, attributes }) {
    kyApi.patch(Routes.api_store_path(id), { json: { store: attributes } });
  },

  zeroItems(_context, { items }) {
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
  ...modalGetters,

  currentStore(state) {
    if (!state.stores) return null;

    return (
      last(sortBy(filter(state.stores, 'viewed_at'), 'viewed_at')) ||
      state.stores[0]
    );
  },

  debouncingOrWaitingOnNetwork(state) {
    return state.collectingDebounces || (state.pendingRequests > 0);
  },
};

const state = {
  ...window.davidrunger.bootstrap,
  ...modalState,
  collectingDebounces: false,
  pendingRequests: 0,
  postingStore: false,
};

export default {
  state,
  actions,
  getters,
  mutations,
};
