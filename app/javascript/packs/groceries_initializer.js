import Vue from 'vendor/customized_vue';
import Groceries from 'groceries/groceries.vue';
import { groceryVuexStoreFactory } from 'groceries/store';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replaced-container'));
  new Vue({
    render: (h) => h(Groceries),
    store: groceryVuexStoreFactory(window.davidrunger.bootstrap),
  }).$mount('replaced-container');
});
