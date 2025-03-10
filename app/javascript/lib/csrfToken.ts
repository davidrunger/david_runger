import { assert } from '@/lib/helpers';

export function csrfToken(): string | null {
  const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');

  if (csrfMetaTag) {
    return assert(csrfMetaTag.getAttribute('content'));
  } else {
    return null;
  }
}
