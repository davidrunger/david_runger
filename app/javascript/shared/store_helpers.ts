interface Identifiable {
  id: number;
}

export function getById<T>(collection: Array<Identifiable & T>, id: number): T {
  const item = safeGetById(collection, id);

  if (item === undefined) {
    throw new TypeError(
      `Could not find item with id ${id} ` +
        `in collection of length ${collection.length} ` +
        `with first item ${JSON.stringify(collection[0])}.`,
    );
  }

  return item;
}

export function safeGetById<T>(
  collection: Array<Identifiable & T>,
  id: number,
): T | undefined {
  return collection.find((collectionItem) => collectionItem.id === id);
}
