import { filter, get, last, pick, sortBy } from 'lodash-es';
import { defineStore } from 'pinia';
import { POSITION } from 'vue-toastification';

import DeletedItemToast from '@/groceries/components/DeletedItemToast.vue';
import { Bootstrap, CheckInStatus, Item } from '@/groceries/types';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { emit } from '@/lib/event_bus';
import { typesafeAssign } from '@/lib/helpers';
import { http } from '@/lib/http';
import { getById, safeGetById } from '@/lib/store_helpers';
import { isObjectWithErrors } from '@/lib/type_predicates';
import { type ObjectWithErrors } from '@/lib/types';
import { toastErrors, vueToast } from '@/lib/vue_toasts';
import {
  api_item_path,
  api_items_bulk_updates_path,
  api_store_items_path,
  api_store_path,
  api_stores_path,
} from '@/rails_assets/routes';
import type { Intersection, Store } from '@/types';
import { ItemCreateResponse } from '@/types/responses/ItemCreateResponse';
import { ItemDestroyResponse } from '@/types/responses/ItemDestroyResponse';
import { ItemUpdateResponse } from '@/types/responses/ItemUpdateResponse';
import { StoreCreateResponse } from '@/types/responses/StoreCreateResponse';
import { StoresIndexResponse } from '@/types/responses/StoresIndexResponse';
import { StoreUpdateResponse } from '@/types/responses/StoreUpdateResponse';

interface State {
  own_stores: Array<Store>;
  spouse_stores: Array<Store>;
  collectingDebounces: boolean;
  pendingRequests: number;
  postingStore: boolean;
  checkInStores: Store[];
}

interface Nameable {
  name: string;
}

export const helpers = {
  sortByName<T>(objects: Array<Nameable & T>): Array<T> {
    return sortBy(objects, (object) => object.name.toLowerCase());
  },
};

const bootstrap = untypedBootstrap as Bootstrap;

export const useGroceriesStore = defineStore('groceries', {
  state: (): State => ({
    own_stores: bootstrap.own_stores,
    spouse_stores: bootstrap.spouse_stores,
    collectingDebounces: false,
    pendingRequests: 0,
    postingStore: false,
    checkInStores: [],
  }),

  actions: {
    addCheckInStore({ store }: { store: Store }) {
      if (this.checkInStores.includes(store)) return;

      this.checkInStores = [...this.checkInStores, store];
    },

    addItem({ store, itemData }: { store?: Store; itemData: Item }) {
      store = store || getById(this.allStores, itemData.store_id);

      // don't add item to store if it's already there
      if (safeGetById(store.items, itemData.id)) return;

      if (!store.items.find((item) => item.id === itemData.id)) {
        store.items.push(itemData);
      }
    },

    async createItem({
      store,
      itemAttributes,
    }: {
      store: Store;
      itemAttributes: { name: string };
    }) {
      this.incrementPendingRequests();

      const itemData = await http.post<
        Intersection<Item, ItemCreateResponse> | ObjectWithErrors
      >(api_store_items_path(store.id), { item: itemAttributes });

      this.decrementPendingRequests();

      if (isObjectWithErrors(itemData)) {
        toastErrors(itemData.errors);
      } else if (itemData) {
        this.addItem({ store, itemData });
        return true;
      }
    },

    async createStore(newStoreName: string) {
      this.postingStore = true;
      const payload = {
        store: {
          name: newStoreName,
        },
      };

      const newStoreData = await http.post<
        Intersection<Store, StoreCreateResponse> | ObjectWithErrors
      >(api_stores_path(), payload);

      this.postingStore = false;

      if (isObjectWithErrors(newStoreData)) {
        toastErrors(newStoreData.errors);
      } else if (newStoreData) {
        this.own_stores.unshift(newStoreData);
        return true;
      }
    },

    decrementPendingRequests() {
      this.pendingRequests -= 1;
    },

    deleteItem({ item }: { item: Item }) {
      const store = getById(this.allStores, item.store_id);
      store.items = store.items.filter((storeItem) => storeItem.id !== item.id);
    },

    async destroyItem({ item }: { item: Item }) {
      this.incrementPendingRequests();

      const { restore_item_path: restoreItemPath } =
        await http.delete<ItemDestroyResponse>(api_item_path(item.id));

      vueToast(
        {
          component: DeletedItemToast,
          props: {
            deletedItemName: item.name,
            restoreItemPath,
          },
        },
        {
          position: POSITION.BOTTOM_RIGHT,
        },
      );

      this.decrementPendingRequests();
      this.deleteItem({ item });
    },

    deleteStore({ store: deletedStore }: { store: Store }) {
      this.own_stores = this.own_stores.filter(
        (store) => store !== deletedStore,
      );
      http.delete(api_store_path(deletedStore.id));
    },

    async pullStoreData() {
      const addOrUpdateStores = (
        storeData: Array<Store>,
        existingStores: Array<Store>,
      ) => {
        for (const storeDatum of storeData) {
          const existingStore = getById(existingStores, storeDatum.id);
          storeDatum.viewed_at =
            get(existingStore, 'viewed_at') ?? storeDatum.viewed_at;
          if (existingStore) {
            const items = [];
            for (const itemDatum of storeDatum.items) {
              const existingItem = getById(existingStore.items, itemDatum.id);
              if (existingItem) {
                Object.assign(existingItem, itemDatum);
                items.push(existingItem);
              } else {
                items.push(itemDatum);
              }
            }
            storeDatum.items = items;
            Object.assign(existingStore, storeDatum);
          } else {
            existingStores.push(storeDatum);
          }
        }
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
      addOrUpdateStores(storesResponse.own_stores, this.own_stores);
      addOrUpdateStores(storesResponse.spouse_stores, this.spouse_stores);
    },

    incrementPendingRequests() {
      this.pendingRequests += 1;
    },

    modifyItem({ item, attributes }: { item?: Item; attributes: Item }) {
      if (!item) {
        const store = getById(this.allStores, attributes.store_id);
        item = getById(store.items, attributes.id);
      }
      Object.assign(item, attributes);
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
      attributes: { name: string };
    }) {
      this.incrementPendingRequests();

      const updatedItemData = await http.patch<
        Intersection<Item, ItemUpdateResponse>
      >(api_item_path(item.id), { item: attributes });

      this.decrementPendingRequests();

      if (!this.debouncingOrWaitingOnNetwork) {
        this.modifyItem({ item, attributes: updatedItemData });
      }
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
        last(sortBy(filter(this.allStores, 'viewed_at'), 'viewed_at')) ||
        this.own_stores[0]
      );
    },

    debouncingOrWaitingOnNetwork(): boolean {
      return this.collectingDebounces || this.pendingRequests > 0;
    },

    isSpouseItem() {
      return (item: Item) => {
        const store = getById(this.allStores, item.store_id);

        return !store.own_store;
      };
    },

    itemsInCart(): Array<Item> {
      return this.neededCheckInItems.filter(
        (item) => item.checkInStatus === 'in-cart',
      );
    },

    neededCheckInItems(): Array<Item> {
      return helpers.sortByName(
        this.checkInStores
          .map((store) => store.items.filter((item) => item.needed > 0))
          .flat(),
      );
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
  },
});
