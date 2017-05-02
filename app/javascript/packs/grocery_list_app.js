import Vue from '../vendor/vue'
import GroceryList from '../grocery_list/app.vue'

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replacedcontainer'))
  const app = new Vue({
    el: 'replacedcontainer',
    template: '<GroceryList/>',
    components: { GroceryList }
  })
})
