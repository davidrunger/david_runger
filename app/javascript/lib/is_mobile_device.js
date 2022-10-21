export function isMobileDevice() {
  return 'ontouchstart' in document.documentElement;
}
