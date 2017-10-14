// eslint-disable-next-line import/no-extraneous-dependencies,import/no-unresolved,import/extensions
import Vue from 'vendor/customized_vue.js';
import TempateShowApp from '../templates/template_show_app.vue';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('hello'));
  new Vue({
    el: 'hello',
    template: '<TempateShowApp/>',
    components: { TempateShowApp },
  });
});
