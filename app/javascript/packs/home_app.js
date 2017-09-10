import Vue from '../vendor/vue'
import Home from '../home/app.vue'

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replacedcontainer'));
  const app = new Vue({
    el: 'replacedcontainer',
    template: '<Home />',
    components: { Home },
  });
});
