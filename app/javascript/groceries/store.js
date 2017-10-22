import axios from 'axios';
import Vuex from 'vuex';
import _ from 'lodash';

const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;

const { bootstrap } = window.davidrunger;

export default new Vuex.Store({
  state: Object.assign({},
    bootstrap,
    {
      postingStore: false,
      currentStore: bootstrap.stores[0],
    },
  ),

  mutations: {
    deleteItem(state, id) {
      state.currentStore.items = state.currentStore.items.filter(item => item.id !== id);
    },

    deleteStore(state, id) {
      state.stores = state.stores.filter(store => store.id !== id);
    },

    selectStore(state, id) {
      state.currentStore = _.find(state.stores, { id });
    },
  },

  actions: {
    deleteItem({ commit }, id) {
      axios.delete(`api/items/${id}`);
      commit('deleteItem', id);
    },

    updateItem(_context, { id, attributes }) {
      axios.patch(`api/items/${id}`, { item: attributes });
    },

    zeroItems(context, items) {
      items.forEach((item) => {
        item.needed = 0;
        axios.patch(`api/items/${item.id}`, {
          item: { needed: 0 },
        });
      });
    },
  },
});
