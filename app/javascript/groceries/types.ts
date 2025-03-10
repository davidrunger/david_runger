import { JsonBroadcast } from '@/lib/types';
import type {
  Intersection,
  Store,
  Item as TypelizerItem,
  UserSerializerBasic,
} from '@/types';
import { GroceriesIndexBootstrap } from '@/types/bootstrap/GroceriesIndexBootstrap';

export type CheckInStatus = 'needed' | 'in-cart' | 'skipped';

export interface Item extends TypelizerItem {
  aboutToMoveTo?: CheckInStatus | null;
  checkInStatus?: CheckInStatus;
}

export interface ItemBroadcast extends JsonBroadcast {
  model: Item;
}

export type Bootstrap = Intersection<
  {
    current_user: UserSerializerBasic;
    spouse: null | UserSerializerBasic;
    own_stores: Array<Store>;
    spouse_stores: Array<Store>;
  },
  GroceriesIndexBootstrap
>;
