// eslint-disable-next-line import/no-extraneous-dependencies,import/no-unresolved,import/extensions
import Vue from 'vendor/customized_vue.js';
import Groceries from '../groceries/groceries.vue';
import store from '../groceries/store';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replacedcontainer'));
  new Vue({
    components: { Groceries },
    el: 'replacedcontainer',
    store,
    template: '<Groceries/>',
  });
});
