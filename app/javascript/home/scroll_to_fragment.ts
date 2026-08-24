const FRAGMENT_SCROLL_TIMEOUTS = [0, 150, 320, 500, 850];

export function setScrollToFragmentTimeouts(
  fragment = window.location.hash.slice(1),
) {
  if (!fragment) return;

  const fragmentTarget = document.getElementById(fragment);
  if (!fragmentTarget) return;

  // retarget scrolling to the element several times. earlier timeouts are so that we
  // scroll there as quickly as possible. later timeouts are because adjustments to the DOM
  // might be changing the scroll position of the target element as the page renders. stop
  // after 850 ms because at that point the user has a reasonable expectation to have full
  // control over their scroll position.
  for (const timeoutMilliseconds of FRAGMENT_SCROLL_TIMEOUTS) {
    setTimeout(() => {
      fragmentTarget.scrollIntoView();
    }, timeoutMilliseconds);
  }
}
