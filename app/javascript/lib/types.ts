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
  alert_toast_messages: Array<string>;
  notice_toast_messages: Array<string>;
};
