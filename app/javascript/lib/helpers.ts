export function assert<T>(value: T | undefined | null): T {
  if (typeof value === 'undefined') {
    throw new Error('[assert] Value was undefined!');
  }

  if (value === null) {
    throw new Error('[assert] Value was null!');
  }

  return value;
}

export function conjunctionList(values: Array<string>): string {
  if (values.length < 2) return values[0] || '';
  if (values.length === 2) return values.join(' and ');

  return `${values.slice(0, -1).join(', ')}, and ${values.at(-1)}`;
}

export function typesafeAssign<T extends object>(
  model: T,
  attributes: Partial<T>,
): T {
  return Object.assign(model, attributes);
}
