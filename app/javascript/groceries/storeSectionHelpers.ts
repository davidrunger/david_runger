import type { Store, StoreSectionScheme } from '@/types';

export function matchingSchemeFor(
  store: Store,
  storeSectionSchemes: Array<StoreSectionScheme>,
): StoreSectionScheme | undefined {
  const storeName = store.name.toLowerCase();
  return storeSectionSchemes.find(
    (scheme) => scheme.name.toLowerCase() === storeName,
  );
}

export function normalizedName(name: string): string {
  return name.trim().replace(/\s+/g, ' ');
}
