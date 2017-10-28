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


  moveItem(state, { itemId, newStoreId }) {
    const item = _.remove(state.currentStore.items, { id: itemId })[0];
    state.currentStore.items = state.currentStore.items.slice(); // use #slice to register? whatevs.
    const newStore = _.find(state.stores, { id: newStoreId });
    newStore.items.push(item);
  },

  selectStore(state, id) {
    state.currentStore = _.find(state.stores, { id });
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

function initialState(bootstrap) {
  return Object.assign({},
    bootstrap,
    {
      postingStore: false,
      currentStore: bootstrap.stores[0],
    },
  );
}

// eslint-disable-next-line import/prefer-default-export
export function groceryVuexStoreFactory(bootstrap) {
  return new Vuex.Store({
    state: initialState(bootstrap),
    mutations,
    actions,
  });
}
