import axios from 'axios';
import Vuex from 'vuex';
import _ from 'lodash';

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
if (csrfMetaTag) {
  const csrfToken = csrfMetaTag.getAttribute('content');
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}

const mutations = {
  deleteItem(state, id) {
    state.currentStore.items = state.currentStore.items.filter(item => item.id !== id);
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

  selectStore(state, id) {
    state.currentStore = _.find(state.stores, { id });
  },

  setCollectingDebounces(state, value) {
    state.collectingDebounces = value;
  },

  setShowModal(state, value) {
    state.showModal = value;
  },
};

const actions = {
  deleteItem({ commit }, id) {
    axios.delete(Routes.api_item_path(id));
    commit('deleteItem', id);
  },

  moveItem({ commit }, { itemId, newStoreId }) {
    commit('moveItem', { itemId, newStoreId });
    axios.patch(Routes.api_item_path(itemId), { item: { store_id: newStoreId } });
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
  debouncingOrWaitingOnNetwork(state) {
    return state.collectingDebounces || (state.pendingRequests > 0);
  },
};

function initialState(bootstrap) {
  return Object.assign({},
    bootstrap,
    {
      collectingDebounces: false,
      currentStore: bootstrap.stores[0],
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
