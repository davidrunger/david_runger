<template lang="pug">
.stores-list__item.flex.items-center.justify-between.my-4.py-2.px-4.js-link.text-xl(
  :class='["leading-[1.15]", { selected: store === currentStore }]'
  @click='groceriesStore.selectStore({ store })'
)
  div.store-name
    a {{store.name}}
    lock-icon.ml-2(v-if='store.private' size='22')
  div.delete-button
    a.js-link(
      v-if='store.own_store'
      @click.stop='destroyStore(store)'
    ) &times;
</template>

<script lang="ts">
import { mapState } from 'pinia';
import { defineComponent, PropType } from 'vue';
import { LockIcon } from 'vue-tabler-icons';

import { useGroceriesStore } from '@/groceries/store';
import { Store } from '@/groceries/types';

export default defineComponent({
  name: 'StoreListEntry',

  components: {
    LockIcon,
  },

  computed: {
    ...mapState(useGroceriesStore, ['currentStore']),
  },

  data() {
    return {
      groceriesStore: useGroceriesStore(),
    };
  },

  methods: {
    destroyStore(store: Store) {
      const confirmation = window.confirm(
        `Are you sure that you want to delete the ${store.name} store and all of its items?`,
      );

      if (confirmation === true) {
        this.groceriesStore.deleteStore({ store });
      }
    },
  },

  props: {
    store: {
      required: true,
      type: Object as PropType<Store>,
    },
  },
});
</script>

<style lang="scss" scoped>
.stores-list__item {
  background: rgba(255, 255, 255, 50%);

  &.selected {
    background: rgba(255, 255, 255, 75%);
    font-weight: bold;
  }
}
</style>
