import _ from 'lodash';
import Gator from 'gator';

let header;
let viewportHeight;
let navlinks = [];
let navlinkedSections = [];
let menuFixed = false;
let forcedActiveLink;
let originalOffsetTop;

function changePositionHandler() {
  window.clickedNavLink = null;
  setHeaderStyle();
  setActiveNavLink();
}

const throttledSavePositionHandler = _.throttle(changePositionHandler, 300, { leading: false });

function setHeaderStyle() {
  originalOffsetTop = originalOffsetTop || header.offsetTop;
  if (!menuFixed && isScrolledBelowHeader()) {
    fixHeader();
  } else if (menuFixed && !isScrolledBelowHeader()) {
    unfixHeader();
  }
}

function setActiveNavLink() {
  navlinks.forEach(el => el.classList.remove('active'));

  let activeNavlink;
  if (forcedActiveLink) {
    activeNavlink = forcedActiveLink;
  } else {
    let highestElementInView = null;
    navlinkedSections.forEach((el) => {
      const yPosition = el.getBoundingClientRect().y;
      if (yPosition > 0 && yPosition < viewportHeight * (2 / 3)) {
        highestElementInView = el;
      }
    });

    if (!highestElementInView) return;

    const section = highestElementInView.attributes['data-section'].value;
    activeNavlink = document.querySelector(`.nav-link[href="#${section}"]`);
  }

  activeNavlink.classList.add('active');
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

function initVariables() {
  header = document.getElementById('header');
  viewportHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
}

function initNavlinkHighlighting() {
  navlinks = [].slice.apply(document.querySelectorAll('.nav-link'));
  navlinkedSections = [].slice.apply(document.querySelectorAll('[data-section]'));
  navlinkedSections.sort((a, b) => a.getBoundingClientRect().y - b.getBoundingClientRect().y);
}

function initHeaderStyling() {
  changePositionHandler();

  document.addEventListener('scroll', throttledSavePositionHandler);
  window.addEventListener('resize', throttledSavePositionHandler);
}

function initNavlinkClickHandling() {
  // we need `this` to be able to be bound to the correct object in the event handler function
  // eslint-disable-next-line func-names
  Gator(document).on('click', '.nav-link', function (_event) {
    forcedActiveLink = this;
    setActiveNavLink();
    setTimeout(() => {
      forcedActiveLink = null;
    }, 1000);
  });
}

// The explicitness of being able to call this as `positionListener.init()` is nice here
// eslint-disable-next-line import/prefer-default-export
export function init() {
  initVariables();
  initHeaderStyling();
  initNavlinkHighlighting();
  initNavlinkClickHandling();
}
