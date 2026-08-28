export function isMobileDevice(): boolean {
  return 'ontouchstart' in document.documentElement;
}
