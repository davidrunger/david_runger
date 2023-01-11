export {}

declare module 'vue' {
  interface ComponentCustomProperties {
    $is_mobile_device: boolean
  }
}
