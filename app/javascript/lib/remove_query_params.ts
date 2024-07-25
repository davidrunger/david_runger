// Clean up URL by removing any query params (for situations where they are no longer needed).
export function removeQueryParams() {
  window.history.replaceState({}, document.title, window.location.pathname);
}
