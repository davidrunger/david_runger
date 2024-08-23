import { JsonBroadcast } from '@/shared/types';
import type {
  Store,
  Item as TypelizerItem,
  UserSerializerBasic,
} from '@/types';

export type CheckInStatus = 'needed' | 'in-cart' | 'skipped';

export interface Item extends TypelizerItem {
  aboutToMoveTo?: CheckInStatus | null;
  checkInStatus?: CheckInStatus;
}

export interface ItemBroadcast extends JsonBroadcast {
  model: Item;
}

export interface Bootstrap {
  current_user: UserSerializerBasic;
  own_stores: Array<Store>;
  spouse_stores: Array<Store>;
}
