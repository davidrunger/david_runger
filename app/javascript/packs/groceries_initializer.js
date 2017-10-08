import Vuex from 'vuex';
import Vue from '../vendor/vue';
import Groceries from '../groceries/groceries.vue';

Vue.use(Vuex);
const store = new Vuex.Store({
  state: {
    count: 0,
  },
  mutations: {
    increment(state) {
      state.count += 1;
    },
  },
});

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replacedcontainer'));
  new Vue({
    components: { Groceries },
    el: 'replacedcontainer',
    store,
    template: '<Groceries/>',
  });
});
