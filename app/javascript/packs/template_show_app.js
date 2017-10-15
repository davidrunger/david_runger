import Vue from 'vendor/customized_vue';
import TempateShowApp from '../templates/template_show_app.vue';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('hello'));
  new Vue({
    el: 'hello',
    template: '<TempateShowApp/>',
    components: { TempateShowApp },
  });
});
