import 'pinia';

import type { Router } from 'vue-router';

// This declares a `router` property for all Pinia stores, even though not all have one.
// https://github.com/vuejs/pinia/discussions/1092#discussioncomment-4909194
declare module 'pinia' {
  export interface PiniaCustomProperties {
    router: Router;
  }
}
