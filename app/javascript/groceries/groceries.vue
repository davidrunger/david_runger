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

<script>
import { mapState } from 'pinia';
import { get } from 'lodash-es';
import Cookies from 'js-cookie';
import actionCableConsumer from '@/channels/consumer';
import { useGroceriesStore } from '@/groceries/store';
import Sidebar from './components/sidebar.vue';
import Store from './components/store.vue';

export default {
  components: {
    Sidebar,
    Store,
  },

  computed: {
    ...mapState(useGroceriesStore, [
      'currentStore',
    ]),
  },

  created() {
    window.addEventListener('beforeunload', this.warnIfRequestPending);

    // https://stackoverflow.com/a/59492869/4009384
    document.addEventListener('touchmove', (event) => {
      if (event.scale !== 1) { event.preventDefault(); }
    }, { passive: false });

    const spouseId = get(window, 'davidrunger.bootstrap.spouse.id');
    if (spouseId) {
      // HACK: add on to the installEventHandlers method because it's called when the ActionCable
      // connection is re-established after having been broken (though it's also called when
      // first loading the page, which we don't need, so ignore that one)
      const originalInstallEventHandlers =
        actionCableConsumer.connection.installEventHandlers.bind(actionCableConsumer.connection);
      let isFirstInstall = true;
      actionCableConsumer.connection.installEventHandlers = () => {
        if (!isFirstInstall) this.groceriesStore.pullStoreData();
        isFirstInstall = false;
        originalInstallEventHandlers();
      };

      actionCableConsumer.subscriptions.create(
        {
          channel: 'GroceriesChannel',
        },
        {
          received: (data) => {
            if (data.action === 'created') {
              this.groceriesStore.addItem({ itemData: data.model });
            } else if (data.action === 'destroyed') {
              this.groceriesStore.deleteItem({ item: data.model });
            } else if (
              data.action === 'updated' &&
                Cookies.get('browser_uuid') !== data.acting_browser_uuid
            ) {
              this.groceriesStore.modifyItem({ attributes: data.model });
            }
          },
        },
      );
    }
  },

  data() {
    return {
      groceriesStore: useGroceriesStore(),
    };
  },

  methods: {
    warnIfRequestPending(event) {
      if (this.debouncingOrWaitingOnNetwork) {
        event.preventDefault();
        // Chrome requires returnValue to be set
        // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
        event.returnValue = '';
      }
    },
  },
};
</script>

<style lang='scss'>
// Disable mobile double-click zooming https://stackoverflow.com/a/54207844/4009384
* {
  touch-action: manipulation;
}

#groceries-app {
  font-size: 0.95rem;
}

main {
  background-image: url("../../assets/images/beach-background.webp");
  z-index: 5;
}

.icon-tabler {
  vertical-align: bottom;
}

// https://stackoverflow.com/a/45769607/4009384
@media screen and (max-width: 767px) {
  input[type="text"],
  input[type="number"],
  input[type="email"],
  input[type="tel"],
  input[type="password"] {
    font-size: 16px;
  }
}
</style>
