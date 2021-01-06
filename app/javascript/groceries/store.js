import axios from 'axios';
import Vue from 'shared/customized_vue';
import Vuex from 'vuex';
import _ from 'lodash';

import * as ModalVuex from 'shared/modal_store';

const mutations = {
  ...ModalVuex.mutations,

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

  moveItem(state, { item, newStore, oldStore }) {
    oldStore.items = _.reject(oldStore.items, { id: item.id });
    newStore.items.push(item);
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
    axios.
      post(Routes.api_store_items_path(store.id), { item: itemAttributes }).
      then(({ data }) => {
        commit('decrementPendingRequests');
        commit('addItem', { store, itemData: data });
      });
  },

  deleteItem({ commit, getters }, { item }) {
    axios.delete(Routes.api_item_path(item.id));
    commit('deleteItem', { item, store: getters.currentStore });
  },

  deleteStore({ commit }, { store }) {
    axios.delete(Routes.api_store_path(store.id));
    commit('deleteStore', { store });
  },

  moveItem({ commit, getters }, { item, newStore }) {
    commit('moveItem', { item, newStore, oldStore: getters.currentStore });
    axios.patch(Routes.api_item_path(item.id), { item: { store_id: newStore.id } });
  },

  selectStore(_context, { store }) {
    // update the store's viewed_at time, bc. this is actually how we determine the selected store
    Vue.set(store, 'viewed_at', (new Date()).toISOString());
    axios.patch(Routes.api_store_path(store.id), { store: _.pick(store, ['viewed_at']) });
  },

  updateItem({ commit }, { item, attributes }) {
    axios.
      patch(Routes.api_item_path(item.id), { item: attributes }).
      then(({ data }) => {
        commit(
          'updateItem',
          { item, updatedItemData: data },
        );
      });
  },

  updateStore(_context, { id, attributes }) {
    axios.patch(Routes.api_store_path(id), { store: attributes });
  },

  zeroItems(_context, { items }) {
    items.forEach((item) => {
      item.needed = 0;
      axios.patch(Routes.api_item_path(item.id), { item: { needed: 0 } });
    });
  },
};

const getters = {
  ...ModalVuex.getters,

  currentStore(state) {
    if (!state.stores) return null;

    return (
      _(state.stores).filter('viewed_at').sortBy(['viewed_at']).last() ||
      state.stores[0]
    );
  },

  debouncingOrWaitingOnNetwork(state) {
    return state.collectingDebounces || (state.pendingRequests > 0);
  },
};

function initialState(bootstrap) {
  return {
    ...bootstrap,
    ...ModalVuex.state,
    collectingDebounces: false,
    current_user: bootstrap.current_user,
    stores: bootstrap.stores,
    pendingRequests: 0,
    postingStore: false,
  };
}

// eslint-disable-next-line import/prefer-default-export
export function groceryVuexStoreFactory(bootstrap) {
  return new Vuex.Store({
    state: initialState(bootstrap),
    actions,
    getters,
    mutations,
  });
}

export default groceryVuexStoreFactory(window.davidrunger.bootstrap);
