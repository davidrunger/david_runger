export function loadAsyncPartials() {
  for (const asyncPartialEl of document.querySelectorAll('[data-async-partial-src]')) {
    const delay = parseInt(asyncPartialEl.dataset.delay || '0', 10);
    setTimeout(fetchPartial.bind(null, asyncPartialEl), delay);
  }
}

async function fetchPartial(asyncPartialEl) {
  const src = asyncPartialEl.dataset.asyncPartialSrc;
  const response = await fetch(src);
  const html = await response.text();
  asyncPartialEl.innerHTML = html;
}
