import { onMounted, onUnmounted } from 'vue';

import { delegate } from '@/lib/event_delegation';
import { trackEvent } from '@/lib/events';
import { isAnchorElement, isMouseEvent } from '@/lib/type_predicates';

export function useExternalLinkTracking() {
  onMounted(() => {
    const cleanup = delegate(document, 'click', 'a[href]', (event, target) => {
      if (
        isMouseEvent(event) &&
        isAnchorElement(target) &&
        isExternalOrSpecialSchemeLink(target)
      ) {
        trackExternalLinkClick(event);
      }
    });

    onUnmounted(cleanup);
  });
}

function isExternalOrSpecialSchemeLink(link: HTMLAnchorElement): boolean {
  try {
    const url = new URL(link.href, window.location.href);

    return (
      url.origin !== window.location.origin ||
      !['http:', 'https:'].includes(url.protocol)
    );
  } catch {
    return false;
  }
}

export function trackExternalLinkClick(event: MouseEvent): void {
  const element = event.target;

  if (element instanceof HTMLAnchorElement) {
    trackEvent('external_link_click', {
      href: element.href,
      page_url: window.location.href,
      text: element.innerText,
    });
  }
}
