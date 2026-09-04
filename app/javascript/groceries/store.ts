import { last, pick, sortBy } from 'es-toolkit';
import { defineStore } from 'pinia';
import { POSITION } from 'vue-toastification';

import { bootstrap } from '@/groceries/bootstrap';
import DeletedItemToast from '@/groceries/components/DeletedItemToast.vue';
import {
  CheckInStatus,
  Item,
  ItemUpdateErrorResponse,
} from '@/groceries/types';
import { emit } from '@/lib/eventBus';
import { typesafeAssign } from '@/lib/helpers';
import { http } from '@/lib/http';
import { safeGetById } from '@/lib/storeHelpers';
import { isObjectWithErrors } from '@/lib/typePredicates';
import { type ObjectWithErrors } from '@/lib/types';
import { toastErrors, vueToast } from '@/lib/vueToasts';
import {
  api_item_merges_path,
  api_item_path,
  api_items_bulk_updates_path,
  api_store_item_section_assignment_path,
  api_store_items_path,
  api_store_path,
  api_store_section_configuration_path,
  api_store_section_scheme_store_section_path,
  api_store_section_scheme_store_sections_path,
  api_store_section_schemes_path,
  api_stores_path,
} from '@/rails_assets/routes';
import type {
  Intersection,
  Store,
  StoreSection,
  StoreSectionScheme,
} from '@/types';
import { DeletedItemRestorationCreateResponse } from '@/types/responses/DeletedItemRestorationCreateResponse';
import { ItemCreateResponse } from '@/types/responses/ItemCreateResponse';
import { ItemDestroyResponse } from '@/types/responses/ItemDestroyResponse';
import { ItemMergeCreateResponse } from '@/types/responses/ItemMergeCreateResponse';
import { ItemUpdateResponse } from '@/types/responses/ItemUpdateResponse';
import { StoreCreateResponse } from '@/types/responses/StoreCreateResponse';
import { StoreSectionSchemesIndexResponse } from '@/types/responses/StoreSectionSchemesIndexResponse';
import { StoresIndexResponse } from '@/types/responses/StoresIndexResponse';
import { StoreUpdateResponse } from '@/types/responses/StoreUpdateResponse';

interface State {
  own_stores: Array<Store>;
  spouse_stores: Array<Store>;
  collectingDebounces: boolean;
  pendingRequests: number;
  postingStore: boolean;
  checkInStores: Store[];
  storeSectionSchemes: Array<StoreSectionScheme>;
}

interface Nameable {
  name: string;
}

interface ItemSectionAssignmentUpdate {
  item: Item;
  store: Store;
  storeSection: StoreSection;
}

interface StoreSectionUpdate {
  name: string;
  storeSection: StoreSection;
  storeSectionScheme: StoreSectionScheme;
}

function canonicalItem(itemData: Item, itemsById: Map<number, Item>): Item {
  const existingItem = itemsById.get(itemData.id);
  if (existingItem) {
    Object.assign(existingItem, itemData);
    return existingItem;
  }

  itemsById.set(itemData.id, itemData);
  return itemData;
}

function canonicalizeStoreItems(stores: Array<Store>): void {
  const itemsById = new Map<number, Item>();

  for (const store of stores) {
    store.items = store.items.map((itemData) =>
      canonicalItem(itemData, itemsById),
    );
  }
}

export const helpers = {
  sortByName<T>(objects: Array<Nameable & T>): Array<T> {
    return sortBy(objects, [(object) => object.name.toLowerCase()]);
  },
};

export const useGroceriesStore = defineStore('groceries', {
  state: (): State => {
    const ownStores = bootstrap.own_stores || [];
    const spouseStores = bootstrap.spouse_stores || [];
    canonicalizeStoreItems([...ownStores, ...spouseStores]);

    return {
      own_stores: ownStores,
      spouse_stores: spouseStores,
      collectingDebounces: false,
      pendingRequests: 0,
      postingStore: false,
      checkInStores: [],
      storeSectionSchemes: [],
    };
  },

  actions: {
    addCheckInStore({ store }: { store: Store }) {
      if (this.checkInStores.includes(store)) return;

      this.checkInStores = [...this.checkInStores, store];
    },

    addItem({ itemData }: { itemData: Item }): Item {
      const item =
        this.allStores
          .flatMap((store) => store.items)
          .find((existingItem) => existingItem.id === itemData.id) || itemData;
      Object.assign(item, itemData);

      const storeIds = new Set(itemData.store_ids);
      for (const store of this.allStores) {
        const storeItem = safeGetById(store.items, item.id);
        if (storeIds.has(store.id) && !storeItem) {
          store.items.push(item);
        } else if (!storeIds.has(store.id) && storeItem) {
          store.items = store.items.filter(({ id }) => id !== item.id);
        }
      }

      return item;
    },

    async createItem({
      store,
      itemAttributes,
    }: {
      store: Store;
      itemAttributes: { name: string };
    }) {
      const itemData = await this.withPendingRequest(() =>
        http.post<Intersection<Item, ItemCreateResponse> | ObjectWithErrors>(
          api_store_items_path(store.id),
          { item: itemAttributes },
        ),
      );

      if (isObjectWithErrors(itemData)) {
        toastErrors(itemData.errors);
      } else if (itemData) {
        return this.addItem({ itemData });
      }
    },

    async createStore(newStoreName: string) {
      this.postingStore = true;
      const payload = {
        store: {
          name: newStoreName,
        },
      };

      try {
        const newStoreData = await http.post<
          Intersection<Store, StoreCreateResponse> | ObjectWithErrors
        >(api_stores_path(), payload);

        if (isObjectWithErrors(newStoreData)) {
          toastErrors(newStoreData.errors);
        } else if (newStoreData) {
          this.own_stores.unshift(newStoreData);
          return true;
        }
      } finally {
        this.postingStore = false;
      }
    },

    async withPendingRequest<T>(request: () => Promise<T>): Promise<T> {
      this.incrementPendingRequests();

      try {
        return await request();
      } finally {
        this.decrementPendingRequests();
      }
    },

    decrementPendingRequests() {
      this.pendingRequests -= 1;
    },

    deleteItem({ item }: { item: Item }) {
      for (const store of this.allStores) {
        store.items = store.items.filter(
          (storeItem) => storeItem.id !== item.id,
        );
      }
    },

    async destroyItem({ item }: { item: Item }) {
      item.deleted = true;

      const { restore_item_path: restoreItemPath } =
        await this.withPendingRequest(() =>
          http.delete<ItemDestroyResponse>(api_item_path(item.id)),
        );

      vueToast(
        {
          component: DeletedItemToast,
          props: {
            deletedItemName: item.name,
            restoreDeletedItem: async () => {
              const restoredItem = await this.withPendingRequest(() =>
                http.post<
                  Intersection<Item, DeletedItemRestorationCreateResponse>
                >(restoreItemPath),
              );
              this.addItem({ itemData: restoredItem });
            },
          },
        },
        {
          position: POSITION.BOTTOM_RIGHT,
          toastClassName: 'groceries-toast',
        },
      );

      this.deleteItem({ item });
    },

    deleteStore({ store: deletedStore }: { store: Store }) {
      for (const item of deletedStore.items) {
        item.store_ids = item.store_ids.filter(
          (storeId) => storeId !== deletedStore.id,
        );
      }
      this.own_stores = this.own_stores.filter(
        (store) => store !== deletedStore,
      );
      http.delete(api_store_path(deletedStore.id));
    },

    async pullStoreData() {
      const itemsById = new Map(
        this.allStores
          .flatMap((store) => store.items)
          .map((item) => [item.id, item]),
      );
      const reconciledStores = (
        storeData: Array<Store>,
        existingStores: Array<Store>,
      ) => {
        const storeIds = new Set(storeData.map((store) => store.id));

        for (const storeDatum of storeData) {
          const existingStore = safeGetById(existingStores, storeDatum.id);
          if (existingStore) {
            storeDatum.viewed_at =
              existingStore.viewed_at ?? storeDatum.viewed_at;
            Object.assign(existingStore, storeDatum);
          } else {
            existingStores.push(storeDatum);
          }

          const store = existingStore || storeDatum;
          store.items = storeDatum.items.map((itemDatum) =>
            canonicalItem(itemDatum, itemsById),
          );
        }

        return existingStores.filter((store) => storeIds.has(store.id));
      };

      const storesResponse = await http.get<
        Intersection<
          {
            own_stores: Array<Store>;
            spouse_stores: Array<Store>;
          },
          StoresIndexResponse
        >
      >(api_stores_path());
      this.own_stores = reconciledStores(
        storesResponse.own_stores,
        this.own_stores,
      );
      this.spouse_stores = reconciledStores(
        storesResponse.spouse_stores,
        this.spouse_stores,
      );
    },

    async pullStoreSectionSchemes() {
      const response = await http.get<StoreSectionSchemesIndexResponse>(
        api_store_section_schemes_path(),
      );
      this.storeSectionSchemes = response.store_section_schemes;
    },

    async createStoreSectionScheme({
      name,
    }: {
      name: string;
    }): Promise<StoreSectionScheme | undefined> {
      const response = await this.withPendingRequest(() =>
        http.post<ObjectWithErrors | null>(api_store_section_schemes_path(), {
          store_section_scheme: { name },
        }),
      );
      if (isObjectWithErrors(response)) {
        toastErrors(response.errors);
        return;
      }

      await this.pullStoreSectionSchemes();
      return this.storeSectionSchemes.find(
        (scheme) => scheme.name.toLowerCase() === name.toLowerCase(),
      );
    },

    async createStoreSection({
      storeSectionScheme,
      name,
    }: {
      storeSectionScheme: StoreSectionScheme;
      name: string;
    }): Promise<boolean> {
      const response = await this.withPendingRequest(() =>
        http.post<ObjectWithErrors | null>(
          api_store_section_scheme_store_sections_path(storeSectionScheme.id),
          { store_section: { name } },
        ),
      );
      if (isObjectWithErrors(response)) {
        toastErrors(response.errors);
        return false;
      }

      await Promise.all([this.pullStoreData(), this.pullStoreSectionSchemes()]);
      return true;
    },

    async deleteStoreSection({
      storeSectionScheme,
      storeSection,
    }: {
      storeSectionScheme: StoreSectionScheme;
      storeSection: StoreSection;
    }) {
      await this.withPendingRequest(() =>
        http.delete(
          api_store_section_scheme_store_section_path(
            storeSectionScheme.id,
            storeSection.id,
          ),
        ),
      );
      await Promise.all([this.pullStoreData(), this.pullStoreSectionSchemes()]);
    },

    async updateStoreSections({
      updates,
    }: {
      updates: Array<StoreSectionUpdate>;
    }): Promise<boolean> {
      if (updates.length === 0) return true;

      const responses = await this.withPendingRequest(() =>
        Promise.all(
          updates.map(({ name, storeSection, storeSectionScheme }) =>
            http.patch<ObjectWithErrors | null>(
              api_store_section_scheme_store_section_path(
                storeSectionScheme.id,
                storeSection.id,
              ),
              { store_section: { name } },
            ),
          ),
        ),
      );

      const errors = responses.flatMap((response) => {
        return isObjectWithErrors(response) ? response.errors : [];
      });
      if (errors.length > 0) {
        toastErrors(errors);
      }

      await Promise.all([this.pullStoreData(), this.pullStoreSectionSchemes()]);
      return errors.length === 0;
    },

    async updateStoreSectionConfiguration({
      store,
      sectioningEnabled,
      storeSectionSchemeId,
    }: {
      store: Store;
      sectioningEnabled: boolean;
      storeSectionSchemeId: number | null;
    }): Promise<boolean> {
      const response = await this.withPendingRequest(() =>
        http.patch<ObjectWithErrors | null>(
          api_store_section_configuration_path(store.id),
          {
            section_configuration: {
              sectioning_enabled: sectioningEnabled,
              store_section_scheme_id: storeSectionSchemeId,
            },
          },
        ),
      );
      if (isObjectWithErrors(response)) {
        toastErrors(response.errors);
        return false;
      }

      await this.pullStoreData();
      return true;
    },

    async updateItemSectionAssignments({
      updates,
    }: {
      updates: Array<ItemSectionAssignmentUpdate>;
    }): Promise<boolean> {
      if (updates.length === 0) return true;

      const responses = await this.withPendingRequest(() =>
        Promise.all(
          updates.map(({ item, store, storeSection }) =>
            http.patch<ObjectWithErrors | null>(
              api_store_item_section_assignment_path(store.id, item.id),
              { section_assignment: { store_section_id: storeSection.id } },
            ),
          ),
        ),
      );

      const errors = responses.flatMap((response) => {
        return isObjectWithErrors(response) ? response.errors : [];
      });
      if (errors.length > 0) {
        toastErrors(errors);
      }

      await this.pullStoreData();
      return errors.length === 0;
    },

    updateItemSectionAssignment(
      update: ItemSectionAssignmentUpdate,
    ): Promise<boolean> {
      return this.updateItemSectionAssignments({ updates: [update] });
    },

    async deleteItemSectionAssignment({
      item,
      store,
    }: {
      item: Item;
      store: Store;
    }) {
      await this.withPendingRequest(() =>
        http.delete(api_store_item_section_assignment_path(store.id, item.id)),
      );
      await this.pullStoreData();
    },

    incrementPendingRequests() {
      this.pendingRequests += 1;
    },

    modifyItem({ item, attributes }: { item?: Item; attributes: Item }) {
      if (item) Object.assign(item, attributes);

      return this.addItem({ itemData: attributes });
    },

    async mergeItems({
      sourceItem,
      targetItem,
    }: {
      sourceItem: Item;
      targetItem: Item;
    }): Promise<Item | ObjectWithErrors> {
      const itemData = await this.withPendingRequest(() =>
        http.post<
          Intersection<Item, ItemMergeCreateResponse> | ObjectWithErrors
        >(api_item_merges_path(), {
          source_item_id: sourceItem.id,
          target_item_id: targetItem.id,
        }),
      );

      if (isObjectWithErrors(itemData)) return itemData;

      this.deleteItem({ item: sourceItem });
      return this.addItem({ itemData });
    },

    selectStore({ store }: { store: Store }) {
      // update the store's viewed_at time so that it will become the `currentStore`
      store.viewed_at = new Date().toISOString();

      // emit event so sidebar can collapse if on mobile
      emit('groceries:store-selected');

      if (store.own_store) {
        http.patch(api_store_path(store.id), {
          store: pick(store, ['viewed_at']),
        });
      }
    },

    setCollectingDebounces({ value }: { value: boolean }) {
      this.collectingDebounces = value;
    },

    setItemAboutToMoveTo({
      item,
      aboutToMoveTo,
    }: {
      item: Item;
      aboutToMoveTo: CheckInStatus | null;
    }) {
      item.aboutToMoveTo = aboutToMoveTo;
    },

    setItemCheckInStatus({
      item,
      checkInStatus,
    }: {
      item: Item;
      checkInStatus: CheckInStatus;
    }) {
      item.checkInStatus = checkInStatus;
    },

    async updateItem({
      item,
      attributes,
    }: {
      item: Item;
      attributes: Partial<Pick<Item, 'name' | 'needed' | 'store_ids'>>;
    }): Promise<Item | ItemUpdateErrorResponse> {
      const updatedItemData = await this.withPendingRequest(() =>
        http.patch<
          Intersection<Item, ItemUpdateResponse> | ItemUpdateErrorResponse
        >(api_item_path(item.id), { item: attributes }),
      );

      if (isObjectWithErrors(updatedItemData)) return updatedItemData;

      if (!this.debouncingOrWaitingOnNetwork) {
        this.modifyItem({ item, attributes: updatedItemData });
      }

      return updatedItemData;
    },

    async updateStore({
      store,
      attributes,
    }: {
      store: Store;
      attributes: {
        name?: string;
        notes?: string | null;
        private?: boolean;
      };
    }) {
      const updatedStoreData = await http.patch<
        Intersection<Store, StoreUpdateResponse>
      >(api_store_path(store.id), { store: attributes });

      typesafeAssign(store, updatedStoreData);
    },

    async zeroItemsInCart() {
      const items = this.itemsInCart;

      await http.post(api_items_bulk_updates_path(), {
        bulk_update: {
          item_ids: items.map((item) => item.id),
          attributes_change: { needed: 0 },
        },
      });

      for (const item of items) {
        item.needed = 0;
        item.checkInStatus = undefined;
      }
    },
  },

  getters: {
    allStores(): Array<Store> {
      return [...this.own_stores, ...this.spouse_stores];
    },

    currentStore(): Store | null {
      if (!this.own_stores) return null;

      return (
        last(
          sortBy(
            this.allStores.filter((store) => store.viewed_at),
            ['viewed_at'],
          ),
        ) || this.own_stores[0]
      );
    },

    debouncingOrWaitingOnNetwork(): boolean {
      return this.collectingDebounces || this.pendingRequests > 0;
    },

    isSpouseItem() {
      return (item: Item) => {
        const store = this.allStores.find((candidateStore) =>
          candidateStore.items.some(({ id }) => id === item.id),
        );

        return !!store && !store.own_store;
      };
    },

    itemOwnStoreNames() {
      return (item: Item): Array<string> =>
        helpers
          .sortByName(
            this.own_stores.filter((store) =>
              item.store_ids.includes(store.id),
            ),
          )
          .map((store) => store.name);
    },

    itemsInCart(): Array<Item> {
      return this.neededCheckInItems.filter(
        (item) => item.checkInStatus === 'in-cart',
      );
    },

    neededCheckInItems(): Array<Item> {
      const itemsById = new Map<number, Item>();
      for (const item of this.checkInStores.flatMap((store) => store.items)) {
        if (item.needed > 0) itemsById.set(item.id, item);
      }

      return helpers.sortByName([...itemsById.values()]);
    },

    neededSkippedCheckInItems(): Array<Item> {
      return helpers.sortByName(
        this.neededCheckInItems.filter(
          (item) => item.checkInStatus === 'skipped',
        ),
      );
    },

    neededUnskippedCheckInItems(): Array<Item> {
      return helpers.sortByName(
        this.neededCheckInItems.filter(
          (item) => item.checkInStatus !== 'skipped',
        ),
      );
    },

    neededUnskippedCheckInItemsInCart(): Array<Item> {
      return helpers.sortByName(
        this.neededUnskippedCheckInItems.filter(
          (item) => item.checkInStatus === 'in-cart',
        ),
      );
    },

    neededUnskippedCheckInItemsNotInCart(): Array<Item> {
      return helpers.sortByName(
        this.neededUnskippedCheckInItems.filter(
          (item) => item.checkInStatus !== 'in-cart',
        ),
      );
    },

    sortedSpouseStores(): Array<Store> {
      return helpers.sortByName(this.spouse_stores);
    },

    sortedStores(): Array<Store> {
      return helpers.sortByName(this.own_stores);
    },

    sortedStoreSectionSchemes(): Array<StoreSectionScheme> {
      return helpers.sortByName(this.storeSectionSchemes);
    },
  },
});
