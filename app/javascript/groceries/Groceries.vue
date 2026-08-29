<template lang="pug">
#groceries-app.flex.h-full.text-base
  Sidebar
  main.z-5.min-h-0.flex-1
    Store(
      v-if="currentStore"
      :store="currentStore"
    )
</template>

<script setup lang="ts">
import type { Subscription } from '@rails/actioncable';
import Cookies from 'js-cookie';
import { storeToRefs } from 'pinia';
import { onBeforeMount, onBeforeUnmount } from 'vue';

import actionCableConsumer from '@/channels/consumer';
import { bootstrap } from '@/groceries/bootstrap';
import { useGroceriesStore } from '@/groceries/store';
import type { ItemBroadcast } from '@/groceries/types';
import type { IphoneTouchEvent } from '@/lib/types';
import { renderBootstrappedToasts } from '@/lib/vueToasts';

import Sidebar from './components/Sidebar.vue';
import Store from './components/Store.vue';

renderBootstrappedToasts();

const groceriesStore = useGroceriesStore();

const { currentStore, debouncingOrWaitingOnNetwork } =
  storeToRefs(groceriesStore);

let groceriesSubscription: Subscription | undefined;

onBeforeMount(() => {
  window.addEventListener('beforeunload', warnIfRequestPending);

  // https://stackoverflow.com/a/59492869/4009384
  document.addEventListener('touchmove', preventPinchZoom, { passive: false });

  const spouseId = bootstrap.spouse?.id;
  if (spouseId) {
    groceriesSubscription = actionCableConsumer.subscriptions.create(
      { channel: 'GroceriesChannel' },
      {
        connected({ reconnected }: { reconnected: boolean }) {
          if (reconnected) void groceriesStore.pullStoreData();
        },

        received: (data: ItemBroadcast) => {
          const initiatedByOwnBrowser =
            Cookies.get('browser_uuid') === data.acting_browser_uuid;

          // NOTE: We try to addItem even if initiatedByOwnBrowser because we
          // might need to re-add the item to the store if it was created by
          // undoing a deletion.
          if (data.action === 'created') {
            groceriesStore.addItem({ itemData: data.model });
          } else if (data.action === 'destroyed' && !initiatedByOwnBrowser) {
            groceriesStore.deleteItem({ item: data.model });
          } else if (data.action === 'updated' && !initiatedByOwnBrowser) {
            groceriesStore.modifyItem({ attributes: data.model });
          }
        },
      },
    );
  }
});

onBeforeUnmount(() => {
  window.removeEventListener('beforeunload', warnIfRequestPending);
  document.removeEventListener('touchmove', preventPinchZoom);
  groceriesSubscription?.unsubscribe();
});

function preventPinchZoom(event: Event) {
  if ((event as IphoneTouchEvent).scale !== 1) {
    event.preventDefault();
  }
}

function warnIfRequestPending(event: BeforeUnloadEvent) {
  if (debouncingOrWaitingOnNetwork.value) {
    event.preventDefault();
    // Chrome requires returnValue to be set
    // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
    event.returnValue = '';
  }
}
</script>

<style lang="scss">
body {
  --groceries-berry: #96576a;
  --groceries-berry-dark: #754052;
  --groceries-cream: #f7f3e9;
  --groceries-ink: #344039;
  --groceries-paper: #fffdf8;
  --groceries-sage: #718168;
  --groceries-sage-dark: #425441;
  --groceries-sage-light: #dfe7d7;
  --groceries-stem: #c6cbb9;
}

#groceries-app {
  --el-border-color: var(--groceries-stem);
  --el-border-color-hover: var(--groceries-sage);
  --el-color-primary: var(--groceries-berry);
  --el-color-primary-light-3: #ae7888;
  --el-color-primary-light-5: #c49aa6;
  --el-color-primary-light-7: #dbc0c7;
  --el-color-primary-light-8: #e7d4d9;
  --el-color-primary-light-9: #f3e9ec;
  --el-color-primary-dark-2: var(--groceries-berry-dark);
  --el-border-radius-base: 12px;

  color: var(--groceries-ink);
  background: var(--groceries-cream);
}

// Disable mobile double-click zooming https://stackoverflow.com/a/54207844/4009384
* {
  touch-action: manipulation;
}

body > header {
  color: var(--groceries-sage-dark);
  background: #f5efe5;
  border-bottom: 1px solid #d8d4c6;
}

main {
  background-color: var(--groceries-cream);
  background-image:
    radial-gradient(ellipse at 5% 0%, rgb(178, 193, 161, 28%), transparent 34%),
    radial-gradient(
      ellipse at 95% 100%,
      rgb(187, 126, 143, 18%),
      transparent 38%
    ),
    linear-gradient(145deg, rgb(255, 253, 248, 70%), transparent 55%);
}

.icon-tabler {
  vertical-align: bottom;
}

.modal-mask {
  background-color: rgb(44, 57, 46, 58%) !important;
  backdrop-filter: blur(2px);
}

.modal-container.bg-white {
  background: var(--groceries-paper);
  border: 1px solid var(--groceries-stem);
  border-radius: 20px;
  box-shadow: 0 20px 55px rgb(45, 57, 47, 25%);
}

.Vue-Toastification__toast.groceries-toast {
  color: var(--groceries-ink);
  background: var(--groceries-paper);
  border: 1px solid var(--groceries-stem);
  border-radius: 16px;
  box-shadow: 0 12px 30px rgb(45, 57, 47, 22%);
}

.groceries-toast {
  .Vue-Toastification__close-button {
    color: var(--groceries-berry-dark);
  }

  .Vue-Toastification__progress-bar {
    background: var(--groceries-berry);
    opacity: 0.55;
  }
}

#groceries-app input[type='checkbox'] {
  accent-color: var(--groceries-berry);
}

// https://stackoverflow.com/a/45769607/4009384
@media screen and (width <= 767px) {
  input[type='text'],
  input[type='number'],
  input[type='email'],
  input[type='tel'],
  input[type='password'] {
    font-size: 16px;
  }
}

input,
textarea {
  background-color: revert;
}
</style>
