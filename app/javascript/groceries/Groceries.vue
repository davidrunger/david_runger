<template lang="pug">
#groceries-app
  #page.flex.dvh-100
    Sidebar
    main.flex-1.bg-cover
      Store(
        v-if='currentStore'
        :store='currentStore'
      )
</template>

<script setup lang="ts">
import { Connection } from '@rails/actioncable';
import Cookies from 'js-cookie';
import { get } from 'lodash-es';
import { storeToRefs } from 'pinia';
import { onBeforeMount } from 'vue';

import actionCableConsumer from '@/channels/consumer';
import { useGroceriesStore } from '@/groceries/store';
import type { ItemBroadcast } from '@/groceries/types';
import type { IphoneTouchEvent } from '@/shared/types';

import Sidebar from './components/Sidebar.vue';
import Store from './components/Store.vue';

interface MonkeypatchedConnection extends Connection {
  installEventHandlers(): void;
}

const groceriesStore = useGroceriesStore();

const { currentStore, debouncingOrWaitingOnNetwork } =
  storeToRefs(groceriesStore);

onBeforeMount(() => {
  window.addEventListener('beforeunload', warnIfRequestPending);

  // https://stackoverflow.com/a/59492869/4009384
  document.addEventListener(
    'touchmove',
    (event) => {
      if ((event as IphoneTouchEvent).scale !== 1) {
        event.preventDefault();
      }
    },
    { passive: false },
  );

  const spouseId = get(window, 'davidrunger.bootstrap.spouse.id');
  if (spouseId) {
    // HACK: add on to the installEventHandlers method because it's called when the ActionCable
    // connection is re-established after having been broken (though it's also called when
    // first loading the page, which we don't need, so ignore that one)
    const originalInstallEventHandlers = (
      actionCableConsumer.connection as MonkeypatchedConnection
    ).installEventHandlers.bind(actionCableConsumer.connection);
    let isFirstInstall = true;
    (
      actionCableConsumer.connection as MonkeypatchedConnection
    ).installEventHandlers = () => {
      if (!isFirstInstall) groceriesStore.pullStoreData();
      isFirstInstall = false;
      originalInstallEventHandlers();
    };

    actionCableConsumer.subscriptions.create(
      {
        channel: 'GroceriesChannel',
      },
      {
        received: (data: ItemBroadcast) => {
          if (Cookies.get('browser_uuid') === data.acting_browser_uuid) return;

          if (data.action === 'created') {
            groceriesStore.addItem({ itemData: data.model });
          } else if (data.action === 'destroyed') {
            groceriesStore.deleteItem({ item: data.model });
          } else if (data.action === 'updated') {
            groceriesStore.modifyItem({ attributes: data.model });
          }
        },
      },
    );
  }
});

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
// Disable mobile double-click zooming https://stackoverflow.com/a/54207844/4009384
* {
  touch-action: manipulation;
}

#groceries-app {
  font-size: 0.95rem;
}

main {
  background-image: url('../../assets/images/beach-background.webp');
  z-index: 5;
}

.icon-tabler {
  vertical-align: bottom;
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
</style>
