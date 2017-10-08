import Vue from '../vendor/vue';
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
