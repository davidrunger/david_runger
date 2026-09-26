import { useHomeStore } from './store';

const FRAGMENT_SCROLL_TIMEOUTS = [0, 150, 320, 500, 850];

// Once a backgrounded tab becomes visible, keep reasserting the scroll position for up to
// this long -- but bail out immediately if the user starts scrolling themselves, since at
// that point they reasonably expect to be in full control.
const VISIBLE_CORRECTION_INTERVAL_MS = 250;
const VISIBLE_CORRECTION_DURATION_MS = 5000;

export function setScrollToFragmentTimeouts(
  fragment = window.location.hash.slice(1),
) {
  if (!fragment) return;

  const fragmentTarget = document.getElementById(fragment);
  if (!fragmentTarget) return;

  const scrollToTarget = () => fragmentTarget.scrollIntoView();

  // Re-target scrolling to the element several times. earlier timeouts are so that we
  // scroll there as quickly as possible. Later timeouts are because adjustments to the DOM
  // (e.g. lazy image loading) might be changing the scroll position of the target element
  // as the page renders. Stop after 850 ms because at that point the user has a reasonable
  // expectation to have full control over their scroll position.
  for (const timeoutMilliseconds of FRAGMENT_SCROLL_TIMEOUTS) {
    setTimeout(scrollToTarget, timeoutMilliseconds);
  }

  // If this page was opened in a background tab (e.g. via Ctrl/Cmd-click), something can
  // reset or prevent the scroll at an unpredictable point after the timeouts above run --
  // and the page has a global `scroll-behavior: smooth`, so retrying with the default
  // (smooth) behavior on a tight interval can keep cancelling/restarting the animation
  // before it ever completes. Once such a tab becomes visible, keep reasserting the scroll
  // *instantly* (bypassing the smooth animation entirely) for a few seconds, bailing out
  // immediately if the user starts scrolling themselves.
  if (document.visibilityState === 'hidden') {
    const homeStore = useHomeStore();

    const scrollToTargetInstantly = () =>
      fragmentTarget.scrollIntoView({ behavior: 'instant', block: 'start' });

    const startCorrectingOnceVisible = () => {
      if (document.visibilityState !== 'visible') return;

      document.removeEventListener(
        'visibilitychange',
        startCorrectingOnceVisible,
      );

      const startedAt = Date.now();
      const intervalId = setInterval(() => {
        if (
          homeStore.userHasScrolled ||
          Date.now() - startedAt > VISIBLE_CORRECTION_DURATION_MS
        ) {
          clearInterval(intervalId);
          return;
        }

        scrollToTargetInstantly();
      }, VISIBLE_CORRECTION_INTERVAL_MS);
    };

    document.addEventListener('visibilitychange', startCorrectingOnceVisible);
  }
}
