export function loadAsyncPartials() {
  document.querySelectorAll('[data-async-partial-src]').forEach(asyncPartialEl => {
    const delay = parseInt(asyncPartialEl.dataset.delay || '0', 10);
    setTimeout(fetchPartial.bind(null, asyncPartialEl), delay);
  });
}

async function fetchPartial(asyncPartialEl) {
  const src = asyncPartialEl.dataset.asyncPartialSrc;
  const response = await fetch(src);
  const html = await response.text();
  asyncPartialEl.innerHTML = html;
}
