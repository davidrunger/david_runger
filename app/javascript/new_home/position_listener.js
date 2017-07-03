let menuFixed = false;
let originalOffsetTop;
const header = document.getElementById('header');

function changePositionHandler(event) {
  originalOffsetTop = originalOffsetTop || header.offsetTop;
  if (!menuFixed && isScrolledBelowHeader()) {
    fixHeader();
  } else if (menuFixed && !isScrolledBelowHeader()) {
    unfixHeader();
  }
}

function isScrolledBelowHeader() {
  return window.scrollY >= originalOffsetTop;
}

function fixHeader() {
  header.classList.add('fixed-top');
  menuFixed = true;
}

function unfixHeader() {
  header.classList.remove('fixed-top');
  menuFixed = false;
}

document.addEventListener('DOMContentLoaded', () => {
  changePositionHandler();

  // !!! debounce this with lodash
  document.addEventListener('scroll', changePositionHandler);

  // !!! debounce this with lodash
  window.addEventListener('resize', changePositionHandler);
});
