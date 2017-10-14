// eslint-disable-next-line import/no-extraneous-dependencies,import/no-unresolved,import/extensions
import Vue from 'vendor/customized_vue.js';
import Home from '../home/home.vue';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('replacedcontainer'));
  new Vue({
    el: 'replacedcontainer',
    template: '<Home />',
    components: { Home },
  });
});
