import Vue from 'vendor/customized_vue';
import Home from '../home/home.vue';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replacedcontainer'));
  new Vue({
    el: 'replacedcontainer',
    template: '<Home />',
    components: { Home },
  });
});
