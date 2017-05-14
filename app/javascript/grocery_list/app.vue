<template lang="pug">
  div
    header
      | Logged in as {{ bootstrap.current_user.email }}
      a(href='/sign_out' data-method='delete' rel='nofollow') Sign Out
    div#page
      aside
        h1.regular.center.black-1 Grocery List
        form(v-on:submit='postNewStore')
          input.float-left(type='text' ref='storeName' v-model='newStoreName'
            placeholder='Add a store'
          )
          input.button.button-outline.float-left.ml2(
            type='submit' value='Add' :disabled='postingStore'
          )
        ul
          li(v-for='store in this.stores')
            a.js-link(v-on:click='selectStore(store)') {{store.name}}
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
        postingStore: false,
        currentStore: this.bootstrap.stores[0],
        newStoreName: '',
        stores: this.bootstrap.stores,
      },
    )
  },

  methods: {
    selectStore(store) {
      this.currentStore = store;
    },

    postNewStore(event) {
      event.preventDefault();
      this.$set(this, 'postingStore', true);
      const payload = {
        store: {
          name: this.newStoreName,
        },
      };
      this.$http.post('api/stores', payload).then(response => {
        this.newStoreName = '';
        this.$set(this, 'postingStore', false);
        const newStore = response.data;
        this.stores.unshift(newStore);
        this.currentStore = newStore;
      });
    },
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
  width: 20vw;
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
