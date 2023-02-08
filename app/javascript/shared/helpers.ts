export function assert<T>(value: T | undefined): T {
  if (typeof value === 'undefined') {
    throw new Error('Value was undefined!');
  }

  return value;
}
