import Vue from '../vendor/vue';
import Groceries from '../groceries/groceries.vue';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replacedcontainer'));
  new Vue({ // eslint-disable-line no-new
    el: 'replacedcontainer',
    template: '<Groceries/>',
    components: { Groceries },
  });
});
