import Vue from '../vendor/vue';
import GroceryList from '../grocery_list/app.vue';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replacedcontainer'));
  new Vue({ // eslint-disable-line no-new
    el: 'replacedcontainer',
    template: '<GroceryList/>',
    components: { GroceryList },
  });
});
