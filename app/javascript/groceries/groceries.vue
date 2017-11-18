<template lang="pug">
  div#groceries-app.sans-serif
    div#page.flex.vh-100
      aside.border-right.border-gray
        div.center.bg-white.bg-lighten-4.p1
          | {{ bootstrap.current_user.email }} #[i.fa.fa-angle-down]
        div
          a.mr1(:href="$routes.edit_user_path(bootstrap.current_user)") Edit Account
          button(
            :href='$routes.destroy_user_session_path()'
            data-method='delete'
            rel='nofollow'
          ) Sign Out
        .p2
          form.add-store.flex(@submit='postNewStore')
            el-input.flex-1.mr1(
              type='text'
              ref='storeName'
              v-model='newStoreName'
              placeholder='Add a store'
            )
            el-input.flex-0(type='submit' value='Add' :disabled='postingStore')
          ul.stores-list
            li.js-link.stores-list__item.h3.my2.py1.px2(
              v-for='store in sortedStores'
              :class='{selected: store === currentStore}'
              @click='$store.commit("selectStore", store.id)'
            )
              drop(@drop='dropItem(store.id, ...arguments)')
                a.store-name {{store.name}}
                a.js-link.right(@click.stop='deleteStore(store)') &times;
      main.flex-1.bg-cover.pl3.pr1.py1
        Store(v-if='currentStore' :store='currentStore')
</template>

<script>
import { mapState } from 'vuex';
import { sortBy } from 'lodash';
import Store from './store.vue';

export default {
  components: {
    Store,
  },

  computed: {
    ...mapState([
      'currentStore',
      'postingStore',
      'stores',
    ]),

    sortedStores() {
      return sortBy(this.stores, store => store.name.toLowerCase());
    },
  },

  data() {
    return {
      newStoreName: '',
    };
  },

  methods: {
    deleteStore(store) {
      this.$http.delete(this.$routes.api_store_path(store.id));
      this.$store.commit('deleteStore', store.id);
    },

    dropItem(storeId, itemData) {
      const itemId = itemData.id;
      const oldStoreId = itemData.store_id;
      this.$store.dispatch('moveItem', {
        itemId,
        newStoreId: storeId,
        oldStoreId,
      });
    },

    postNewStore(event) {
      event.preventDefault();
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
        this.stores.unshift(newStore);
        this.$store.commit('selectStore', newStore.id);
      });
    },
  },
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

main {
  background-image: url('~img/beach-background.jpg');
}

.stores-list__item {
  background: rgba(255, 255, 255, 0.5);

  &.selected {
    background: rgba(255, 255, 255, 0.75);
    font-weight: bold;
  }
}
</style>
