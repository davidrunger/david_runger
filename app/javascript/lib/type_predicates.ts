export function isArrayOfStrings(object: unknown): object is Array<string> {
  return (
    Array.isArray(object) &&
    object.every((element) => typeof element === 'string')
  );
}
