<template lang="pug">
  div
    header
      | Logged in as {{ bootstrap.current_user.email }}
      a(href='/sign_out' data-method='delete' rel='nofollow') Sign Out
    div#page
      aside
        h1.regular.center.black-1 Grocery List
        div(v-if='loadingStores') Loading...
        div(v-else)
          ul
            li(v-for='store in this.stores')
              a.js-link(v-on:click='selectStore(store)') {{store.name}}
          a.h3.js-link(v-if='!addingStore' v-on:click='toggleAddingStore') Add a store #[span.bold +]
          form(v-if='addingStore' v-on:submit='postNewStore')
            input#store-name-input.float-left(type='text' ref='storeName' v-model='newStoreName'
              placeholder='Enter the store name'
            )
            input#add-store-button.button.button-outline.float-left.ml2(type='submit' value='Add')
            a.h3.js-link(v-on:click='toggleAddingStore') Cancel
      main
        Store(v-if='currentStore' :store='currentStore')
</template>

<script>
import { find } from 'lodash';

const Store = require('./store.vue');

export default {
  components: {
    Store
  },

  data() {
    return Object.assign({},
      this.bootstrap,
      {
        addingStore: false,
        currentStore: null,
        loadingStores: false,
        newStoreName: '',
        stores: [],
      },
    )
  },

  methods: {
    selectStore(store) {
      this.currentStore = store;
    },

    postNewStore(event) {
      event.preventDefault();
      const payload = {
        store: {
          name: this.newStoreName,
        },
      };
      this.$http.post('api/stores', payload).then(response => {
        this.newStoreName = '';
        this.$set(this, 'addingStore', false);
        this.stores.push(payload.store);
      });
    },

    toggleAddingStore() {
      this.$set(this, 'addingStore', !this.addingStore);
      if (this.addingStore) this.$nextTick(() => this.$refs.storeName.focus());
    },
  },

  mounted() {
    this.loadingStores = true;
    this.$http.get('/api/stores').then(({ data }) => {
      this.stores = data;
      this.currentStore = this.currentStore || this.stores[0];
      this.loadingStores = false;
    });
  },
}
</script>

<style lang='scss' scoped>
$header_height: 40px;
header {
  height: $header_height;
  background: pink;
}
aside {
  width: 15vw;
  min-width: 160px;
  max-width: 300px;
  background: lightgreen;
}
main {
  flex: 1;
  background: lightblue;
}
#page {
  display: flex;
  height: calc(100vh - #{$header_height});
}
</style>
