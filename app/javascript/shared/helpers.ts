export function assert<T>(value: T | undefined | null): T {
  if (typeof value === 'undefined') {
    throw new Error('[assert] Value was undefined!');
  }

  if (value === null) {
    throw new Error('[assert] Value was null!');
  }

  return value;
}

export function typesafeAssign<T extends object>(
  model: T,
  attributes: Partial<T>,
): T {
  return Object.assign(model, attributes);
}
