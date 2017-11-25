import axios from 'axios';
import Vue from 'vendor/customized_vue';
import Vuex from 'vuex';
import _ from 'lodash';

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
if (csrfMetaTag) {
  const csrfToken = csrfMetaTag.getAttribute('content');
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}

// export for testing
export const mutations = {
  deleteItem(state, { itemId, storeId }) {
    const store = _.find(state.stores, { id: storeId });
    store.items = store.items.filter(item => item.id !== itemId);
  },

  deleteStore(state, id) {
    state.stores = state.stores.filter(store => store.id !== id);
  },

  decrementPendingRequests(state) {
    state.pendingRequests -= 1;
  },

  incrementPendingRequests(state) {
    state.pendingRequests += 1;
  },

  moveItem(state, { itemId, newStoreId }) {
    const item = _.remove(state.currentStore.items, { id: itemId })[0];
    state.currentStore.items = state.currentStore.items.slice(); // use #slice to register? whatevs.
    const newStore = _.find(state.stores, { id: newStoreId });
    newStore.items.push(item);
  },

  setCollectingDebounces(state, value) {
    state.collectingDebounces = value;
  },

  setShowModal(state, value) {
    state.showModal = value;
  },
};

const actions = {
  deleteItem({ commit, getters }, id) {
    axios.delete(Routes.api_item_path(id));
    commit('deleteItem', {
      itemId: id,
      storeId: getters.currentStore.id,
    });
  },

  moveItem({ commit }, { itemId, newStoreId }) {
    commit('moveItem', { itemId, newStoreId });
    axios.patch(Routes.api_item_path(itemId), { item: { store_id: newStoreId } });
  },

  selectStore({ state }, id) {
    const store = _.find(state.stores, { id });
    Vue.set(store, 'viewed_at', Date());
    axios.patch(Routes.api_store_path(id), { store: _.pick(store, ['viewed_at']) });
  },

  updateItem(_context, { id, attributes }) {
    axios.patch(Routes.api_item_path(id), { item: attributes });
  },

  zeroItems(context, items) {
    items.forEach((item) => {
      item.needed = 0;
      axios.patch(Routes.api_item_path(item.id), {
        item: { needed: 0 },
      });
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
};

// export for testing
export function initialState(bootstrap) {
  return Object.assign({},
    bootstrap,
    {
      collectingDebounces: false,
      stores: bootstrap.stores,
      pendingRequests: 0,
      postingStore: false,
      showModal: false,
    },
  );
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
