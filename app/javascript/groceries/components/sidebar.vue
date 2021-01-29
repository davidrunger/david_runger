<template lang='pug'>
aside.border-right.border-gray
  LoggedInHeader.mb2
  .p2
    form.add-store.flex(@submit.prevent='createStore')
      .flex-1.mr1
        el-input(
          type='text'
          v-model='newStoreName'
          name='newStoreName'
          placeholder='Add a store'
          size='medium'
        )
      el-button.flex-0(
        native-type='submit'
        :disabled='postingStore'
        size='medium'
      ) Add
    .stores-list
      .js-link.stores-list__item.h3.my2.py1.px2(
        v-for='store in sortedStores'
        :class='{selected: store === currentStore}'
        @click='$store.dispatch("selectStore", { store })'
      )
        div
          a.store-name {{store.name}}
          a.js-link.right(@click.stop="$store.dispatch('deleteStore', { store })") &times;
</template>

<script>
import { mapGetters, mapState } from 'vuex';
import _ from 'lodash';

import LoggedInHeader from './logged_in_header.vue';

export default {
  name: 'Sidebar',

  components: {
    LoggedInHeader,
  },

  computed: {
    ...mapGetters([
      'currentStore',
    ]),

    ...mapState([
      'postingStore',
      'stores',
    ]),

    sortedStores() {
      return _.sortBy(this.stores, store => store.name.toLowerCase());
    },
  },

  data() {
    return {
      newStoreName: '',
    };
  },

  methods: {
    createStore() {
      this.$store.state.postingStore = true;
      const payload = {
        store: {
          name: this.newStoreName,
        },
      };
      this.$http.post(this.$routes.api_stores_path(), payload).then(response => {
        this.newStoreName = '';
        this.$store.state.postingStore = false;
        const newStore = response.data;
        newStore.viewed_at = (new Date(newStore.viewed_at)).toISOString();
        this.stores.unshift(newStore);
      });
    },
  },

  props: {},
};
</script>

<style lang='scss' scoped>
aside {
  background: linear-gradient(to bottom, #458fc0 0%, #a8b2ce 50%, #b6bcd5 100%);

  @media screen and (max-width: 399px) {
    min-width: 150px;
    width: 45vw;
    max-width: 180px;
  }

  @media screen and (min-width: 400px) {
    min-width: 180px;
    width: 35vw;
    max-width: 280px;
  }
}

.stores-list__item {
  background: rgba(255, 255, 255, 0.5);

  &.selected {
    background: rgba(255, 255, 255, 0.75);
    font-weight: bold;
  }
}
</style>
