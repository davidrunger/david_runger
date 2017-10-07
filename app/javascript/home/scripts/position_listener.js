import _ from 'lodash';
import Gator from 'gator';
import 'waypoints/lib/noframework.waypoints'; // adds `Waypoint` to window
import 'waypoints/lib/shortcuts/inview'; // adds `Inview` to `Waypoint`

let forcedActiveNavIdSetAt;
let forcedActiveNavId;

function forcedNavIdIsCurrent() {
  return (new Date()).getTime() < (forcedActiveNavIdSetAt + 1000);
}

const sectionsFullyInView = [];
const sectionsPartiallyInView = [];
function getActiveNavlink() {
  let activeNavId;
  if (forcedActiveNavId && forcedNavIdIsCurrent()) {
    activeNavId = forcedActiveNavId;
  } else {
    activeNavId = sectionsFullyInView[0] || sectionsPartiallyInView[0] || null;
  }

  if (activeNavId) {
    return document.querySelector(`.nav-link[href="${activeNavId}"]`);
  } else {
    return null;
  }
}

function clearNavlinkHighlights() {
  const navlinks = getNavlinks();
  navlinks.forEach(el => el.classList.remove('active'));
}

function highlightActiveNavlink() {
  const activeNavlink = getActiveNavlink();
  if (activeNavlink) activeNavlink.classList.add('active');;
}

function updateHighlightedNavlink() {
  clearNavlinkHighlights();
  highlightActiveNavlink();
}

function initNavlinkClickHandling() {
  // we need `this` to be able to be bound to the correct object in the event handler function
  // eslint-disable-next-line func-names
  Gator(document).on('click', '.nav-link', function (_event) {
    forcedActiveNavIdSetAt = (new Date()).getTime();
    forcedActiveNavId = this.getAttribute('href');
    updateHighlightedNavlink();
  });
}

let navlinks;
function getNavlinks() {
  if (!navlinks) {
    navlinks = [].slice.apply(document.querySelectorAll('.nav-link'));
  }
  return navlinks;
}

function getScrollHooks() {
  return [].slice.apply(document.querySelectorAll(`[data-section] .js-scroll-hook`));
}

// The explicitness of being able to call this as `positionListener.init()` is nice here
// eslint-disable-next-line import/prefer-default-export
export function init() {
  getScrollHooks().forEach((scrollHook) => {
    const scrollHookId = scrollHook.parentElement.getAttribute('data-section');
    const scrollHookHash = `#${scrollHookId}`;
    new Waypoint.Inview({ // eslint-disable-line no-new,no-undef
      element: scrollHook,
      enter(direction) {
        if (scrollHookHash === '#') return;

        sectionsPartiallyInView.push(scrollHookHash);
        updateHighlightedNavlink();
      },
      entered(direction) {
        if (scrollHookHash === '#') return;

        sectionsFullyInView.push(scrollHookHash);
        updateHighlightedNavlink();
      },
      exit(direction) {
        if (scrollHookHash === '#') return;

        _.remove(sectionsFullyInView, hash => hash === scrollHookHash);
        updateHighlightedNavlink();
      },
      exited(direction) {
        if (scrollHookHash === '#') return;

        _.remove(sectionsFullyInView, hash => hash === scrollHookHash);
        _.remove(sectionsPartiallyInView, hash => hash === scrollHookHash);
        updateHighlightedNavlink();
      },
    });
  });

  initNavlinkClickHandling();
}
