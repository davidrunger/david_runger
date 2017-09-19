import Vue from '../vendor/vue';
import TempateShowApp from '../templates/template_show_app.vue';

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('hello'));
  new Vue({ // eslint-disable-line no-new
    el: 'hello',
    template: '<TempateShowApp/>',
    components: { TempateShowApp },
  });
});
