export function windowLocationWithHash(hash: string) {
  const pageUrl = new URL(window.location.href);
  pageUrl.hash = `#${hash}`;
  return pageUrl.toString();
}
