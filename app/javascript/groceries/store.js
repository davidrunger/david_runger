import axios from 'axios';
import Vue from 'shared/customized_vue';
import Vuex from 'vuex';
import _ from 'lodash';

// export for testing
export const mutations = {
  deleteItem(state, { item, store }) {
    store.items = store.items.filter(storeItem => storeItem !== item);
  },

  deleteStore(state, { store: deletedStore }) {
    state.stores = state.stores.filter(store => store !== deletedStore);
  },

  decrementPendingRequests(state) {
    state.pendingRequests -= 1;
  },

  hideModal(state, { modalName }) {
    state.modalsShowing = state.modalsShowing.filter(showingModal => showingModal !== modalName);
  },

  hideTopModal(state) {
    state.modalsShowing = state.modalsShowing.slice(0, -1); // all but the last element
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

  showModal(state, { modalName }) {
    if (state.modalsShowing.indexOf(modalName) === -1) {
      state.modalsShowing.push(modalName);
    }
  },
};

const actions = {
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
    Vue.set(store, 'viewed_at', (new Date()).toISOString());
    axios.patch(Routes.api_store_path(store.id), { store: _.pick(store, ['viewed_at']) });
  },

  updateItem(_context, { id, attributes }) {
    axios.patch(Routes.api_item_path(id), { item: attributes });
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
  currentStore(state) {
    return (
      _(state.stores).filter('viewed_at').sortBy(['viewed_at']).last() ||
      state.stores[0]
    );
  },

  debouncingOrWaitingOnNetwork(state) {
    return state.collectingDebounces || (state.pendingRequests > 0);
  },

  showingModal(state) {
    return ({ modalName }) => {
      return state.modalsShowing.indexOf(modalName) !== -1;
    };
  },
};

// export for testing
export function initialState(bootstrap) {
  return {
    ...bootstrap,
    collectingDebounces: false,
    current_user: bootstrap.current_user,
    stores: bootstrap.stores,
    pendingRequests: 0,
    postingStore: false,
    modalsShowing: [],
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
