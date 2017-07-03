import * as h from '../helpers';

function scrollToTop() {
  window.scroll(0, 0);
}

document.addEventListener('DOMContentLoaded', () => {
  h.delegate(document, '.js-scroll-top', 'click', scrollToTop);
});
