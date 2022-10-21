<template lang='pug'>
.flex.js-link.stores-list__item.h3.my2.py1.px2.items-center.justify-between(
  :class='{selected: store === currentStore}'
  @click='$store.dispatch("selectStore", { store })'
)
  div.store-name
    a {{store.name}}
    lock-icon.ml1(v-if='store.private' size='22')
  div.delete-button
    a.js-link(
      v-if='store.own_store'
      @click.stop='destroyStore(store)'
    ) &times;
</template>

<script>
import { mapGetters } from 'vuex';
import { LockIcon } from 'vue-tabler-icons';

export default {
  name: 'StoreListEntry',

  components: {
    LockIcon,
  },

  computed: {
    ...mapGetters([
      'currentStore',
    ]),
  },

  methods: {
    destroyStore(store) {
      const confirmation = window.confirm(
        `Are you sure that you want to delete the ${store.name} store and all of its items?`,
      );

      if (confirmation === true) {
        this.$store.dispatch('deleteStore', { store });
      }
    },
  },

  props: {
    store: {
      required: true,
      type: Object,
    },
  },
};
</script>

<style lang='scss' scoped>
.stores-list__item {
  background: rgba(255, 255, 255, 50%);

  &.selected {
    background: rgba(255, 255, 255, 75%);
    font-weight: bold;
  }
}
</style>
