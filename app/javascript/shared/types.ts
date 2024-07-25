export interface JsonBroadcast {
  acting_browser_uuid: string;
  action: 'created' | 'updated' | 'destroyed';
  model: object;
}

export interface IphoneTouchEvent extends TouchEvent {
  scale: number;
}
