<template lang="pug">
  div#groceries-app
    header
      span Logged in as {{ bootstrap.current_user.email }}
      | &nbsp;
      a(:href="$routes.edit_user_path(bootstrap.current_user)") Edit Account
      | &nbsp;
      button.sign-out(
        :href='$routes.destroy_user_session_path()'
        data-method='delete'
        rel='nofollow'
      ) Sign Out
    div#page
      aside
        h1.regular.center.black-1.xs-mb10 Groceries
        form.add-store(@submit='postNewStore')
          input.float-left(type='text' ref='storeName' v-model='newStoreName'
            placeholder='Add a store'
          )
          input.button.button-outline.float-left.ml2(
            type='submit' value='Add' :disabled='postingStore'
          )
        ul.stores-list
          li.stores-list__item(
            v-for='store in sortedStores'
            :class='{selected: store === $store.state.currentStore}'
          )
            drop(@drop='dropItem(store.id, ...arguments)')
              a.js-link.store-name(@click='$store.commit("selectStore", store.id)') {{store.name}}
              button.js-link.delete(@click='deleteStore(store)') ×
      main
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
    sortedStores() {
      return sortBy(this.stores, store => store.name.toLowerCase());
    },
    ...mapState([
      'currentStore',
      'postingStore',
      'stores',
    ]),
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

    selectStore(store) {
      this.currentStore = store;
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
        this.currentStore = newStore;
      });
    },
  },
};
</script>

<style lang='scss' scoped>
$header_height: 20px;

#groceries-app { font-family: "Open Sans", sans-serif; }

header {
  height: $header_height;
  text-align: center;
  background: #b8adff;
}

#page {
  display: flex;
  min-height: calc(100vh - #{$header_height});
}

aside {
  padding: 10px;
  background: lightgreen;

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
  flex: 1;
  padding: 10px;
  background: lightblue;
}

.sign-out { margin-left: 10px; }

h1 {
  font-size: 25px;
  text-align: center;
}

form.add-store { text-align: center; }

.stores-list__item {
  display: flex;
  background: rgba(255, 255, 255, 0.5);
  font-size: 20px;
  margin: 15px;
  padding: 5px 10px;

  &.selected {
    background: rgba(255, 255, 255, 0.8);
    font-weight: bold;
  }

  .store-name {
    flex: 1;
  }

  .delete {
    color: crimson;
    height: 20px;
    width: 20px;
    margin-left: 10px;
    font-weight: bold;
    font-size: 15px;
    text-align: center;
    padding: 0;
  }
}
</style>
