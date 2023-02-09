export function assert<T>(value: T | undefined | null): T {
  if (typeof value === 'undefined') {
    throw new Error('Value was undefined!');
  }

  if (value === null) {
    throw new Error('Value was null!');
  }

  return value;
}
