import { assert } from '@/lib/helpers';

export function loadAsyncPartials() {
  for (const asyncPartialEl of Array.from(
    document.querySelectorAll('[data-async-partial-src]'),
  )) {
    if (asyncPartialEl instanceof HTMLElement) {
      const delay = parseInt(asyncPartialEl.dataset.delay || '0', 10);
      setTimeout(() => {
        void fetchPartial(asyncPartialEl);
      }, delay);
    }
  }
}

async function fetchPartial(asyncPartialEl: HTMLElement) {
  const src = assert(asyncPartialEl.dataset.asyncPartialSrc);
  const response = await fetch(src);
  const html = await response.text();
  asyncPartialEl.innerHTML = html;
}
