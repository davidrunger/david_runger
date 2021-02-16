export function loadAsyncPartials() {
  document.querySelectorAll('[data-async-partial-src]').forEach(asyncPartialEl => {
    const delay = parseInt(asyncPartialEl.dataset.delay || '0', 10);
    setTimeout(fetchPartial.bind(null, asyncPartialEl), delay);
  });
}

function fetchPartial(asyncPartialEl) {
  const src = asyncPartialEl.dataset.asyncPartialSrc;
  fetch(src).
    then(response => response.text()).
    then(html => { asyncPartialEl.innerHTML = html; });
}
