import { JsonBroadcast } from '@/shared/types';

export interface Item {
  id: number;
  in_cart?: boolean;
  name: string;
  needed: number;
  newlyAdded: boolean;
  skipped?: boolean;
  store_id: number;
}

export interface Store {
  id: number;
  items: Array<Item>;
  name: string;
  notes: string;
  own_store: boolean;
  private: boolean;
  viewed_at: string;
}

export interface ItemBroadcast extends JsonBroadcast {
  model: Item;
}

export interface Bootstrap {
  current_user: {
    email: string;
    id: number;
  };
  own_stores: Array<Store>;
  spouse_stores: Array<Store>;
}
