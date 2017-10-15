import Vue from 'vendor/customized_vue';
import Groceries from '../groceries/groceries.vue';
import store from '../groceries/store';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replaced-container'));
  new Vue({
    render: (h) => h(Groceries),
    store,
  }).$mount('replaced-container');
});
