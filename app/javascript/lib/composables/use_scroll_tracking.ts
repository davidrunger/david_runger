import { onMounted, onUnmounted } from 'vue';

import { trackEvent } from '@/lib/events';

let trackedScrollEvent = false

function trackScrollEvent() {
  if (!trackedScrollEvent) {
    trackEvent('scroll', {
      page_url: window.location.href,
    });

    trackedScrollEvent = true;
  }
}

export function useScrollTracking() {
  onMounted(() => {
    window.addEventListener('scroll', trackScrollEvent);

    onUnmounted(() => {
      window.removeEventListener('scroll', trackScrollEvent);
    });
  });
}
