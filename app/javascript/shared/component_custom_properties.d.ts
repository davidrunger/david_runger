import * as Routes from '@/rails_assets/routes';

export {};

declare module 'vue' {
  interface ComponentCustomProperties {
    $bootstrap: object
    $is_mobile_device: boolean
    $routes: typeof Routes
  }
}
