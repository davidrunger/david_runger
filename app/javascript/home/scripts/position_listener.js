import _ from 'lodash';
import Gator from 'gator';
import 'waypoints/lib/noframework.waypoints'; // adds `Waypoint` to window
import 'waypoints/lib/shortcuts/inview'; // adds `Inview` to `Waypoint`

import { on } from '@/lib/event_bus';

let forcedActiveNavIdSetAt;
let forcedActiveNavId;

function forcedNavIdIsCurrent() {
  return (new Date()).getTime() < (forcedActiveNavIdSetAt + 1000);
}

const sectionsFullyInView = [];
const sectionsPartiallyInView = [];
function getActiveNavlink(scrollDirection) {
  let activeNavId;
  if (forcedActiveNavId && forcedNavIdIsCurrent()) {
    activeNavId = forcedActiveNavId;
  } else if (scrollDirection === 'up') {
    activeNavId = sectionsFullyInView[0] || sectionsPartiallyInView[0] || null;
  } else {
    activeNavId = _.last(sectionsFullyInView) || _.last(sectionsPartiallyInView) || null;
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

function highlightActiveNavlink(scrollDirection) {
  const activeNavlink = getActiveNavlink(scrollDirection);
  if (activeNavlink) activeNavlink.classList.add('active');
}

function updateHighlightedNavlink(scrollDirection) {
  clearNavlinkHighlights();
  highlightActiveNavlink(scrollDirection);
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
  return [].slice.apply(document.querySelectorAll('[data-section] .js-scroll-hook'));
}

// Image loading can alter page layout (increasing height), so refresh waypoints when that happens.
function initImageLoadedRefreshing() {
  const throttledRefreshAll = _.throttle(refreshAll, 1000, { leading: false });
  on('performant-image:image-loaded', throttledRefreshAll);
}

function refreshAll() {
  window.requestAnimationFrame(() => window.Waypoint.refreshAll());
}

// The explicitness of being able to call this as `positionListener.init()` is nice here
// eslint-disable-next-line import/prefer-default-export
export function init() {
  getScrollHooks().forEach((scrollHook) => {
    const scrollHookId = scrollHook.parentElement.getAttribute('data-section');
    const scrollHookHash = `#${scrollHookId}`;
    new Waypoint.Inview({ // eslint-disable-line no-undef
      element: scrollHook,
      enter(direction) {
        if (scrollHookHash === '#') return;

        sectionsPartiallyInView.push(scrollHookHash);
        updateHighlightedNavlink(direction);
      },
      entered(direction) {
        if (scrollHookHash === '#') return;

        if (scrollHook.getBoundingClientRect().top > 0) sectionsFullyInView.push(scrollHookHash);
        updateHighlightedNavlink(direction);
      },
      exit(direction) {
        if (scrollHookHash === '#') return;

        _.remove(sectionsFullyInView, hash => hash === scrollHookHash);
        updateHighlightedNavlink(direction);
      },
      exited(direction) {
        if (scrollHookHash === '#') return;

        _.remove(sectionsFullyInView, hash => hash === scrollHookHash);
        _.remove(sectionsPartiallyInView, hash => hash === scrollHookHash);
        updateHighlightedNavlink(direction);
      },
    });
  });

  initNavlinkClickHandling();
  initImageLoadedRefreshing();
}
