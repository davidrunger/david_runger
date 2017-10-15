import Vue from 'vendor/customized_vue';
import Home from '../home/home.vue';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replaced-container'));
  new Vue({
    render: (h) => h(Home),
  }).$mount('replaced-container');
});
