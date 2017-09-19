<template lang="pug">
  div#grocery-app
    header
      span Logged in as {{ bootstrap.current_user.email }}
      a.sign-out(href='/sign_out' data-method='delete' rel='nofollow') Sign Out
    div#page
      aside
        h1.regular.center.black-1.xs-mb10 Grocery List
        form.add-store(v-on:submit='postNewStore')
          input.float-left(type='text' ref='storeName' v-model='newStoreName'
            placeholder='Add a store'
          )
          input.button.button-outline.float-left.ml2(
            type='submit' value='Add' :disabled='postingStore'
          )
        ul.stores-list
          li.stores-list__item(v-for='store in this.stores')
            a.js-link.store-name(v-on:click='selectStore(store)') {{store.name}}
            button.js-link.delete(v-on:click='deleteStore(store)') ×
      main
        Store(v-if='currentStore' :store='currentStore')
</template>

<script>
const Store = require('./store.vue');

export default {
  components: {
    Store,
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
    );
  },

  methods: {
    deleteStore(store) {
      this.$http.delete(`api/stores/${store.id}`);
      this.stores = this.stores.filter(otherStore => otherStore.id !== store.id);
    },

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
};
</script>

<style lang='scss' scoped>
$header_height: 20px;

#grocery-app { font-family: "Open Sans", sans-serif; }

header {
  height: $header_height;
  text-align: center;
  background: #b8adff;
}

#page {
  display: flex;
  height: calc(100vh - #{$header_height});
}

aside {
  padding: 10px;
  background: lightgreen;

  @media screen and (max-width:399px) {
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
