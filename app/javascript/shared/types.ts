export interface JsonBroadcast {
  acting_browser_uuid: string
  action: string
  model: object
}

export interface IphoneTouchEvent extends TouchEvent {
  scale: number
}
