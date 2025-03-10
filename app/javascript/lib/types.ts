import { UserSerializerBasic } from '@/types';

export interface JsonBroadcast {
  acting_browser_uuid: string;
  action: 'created' | 'updated' | 'destroyed';
  model: object;
}

export interface IphoneTouchEvent extends TouchEvent {
  scale: number;
}

export type UniversalBootstrapData = {
  current_user?: UserSerializerBasic;
  nonce: string;
  toast_messages: Array<string>;
};
