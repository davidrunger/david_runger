<template lang="pug">
  div
    h1.regular.center.black-1 Grocery List
    div(v-if='loadingStores') Loading...
    div(v-else)
      section.store(v-for='store in this.stores')
        Store(:store='store')
      a.h3.js-link(v-on:click='toggleAddingStore')
        span(v-if='addingStore') Cancel #[span.bold &ndash;]
        span(v-else) Add a store #[span.bold +]
      form(v-if='addingStore' v-on:submit='postNewStore')
        input#store-name-input.float-left(type='text' ref='storeName' v-model='newStoreName'
          placeholder='Enter the store name'
        )
        input#add-store-button.button.button-outline.float-left.ml2(type='submit' value='Add')
        .clearfix
</template>

<script>
const Store = require('./store.vue');

module.exports = {
  components: {
    Store
  },

  data() {
    return {
      addingStore: false,
      loadingStores: false,
      newStoreName: '',
      stores: [],
    }
  },

  methods: {
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
      this.loadingStores = false;
    });
  },
}
</script>

<style scoped>
#new-store-form {
  max-width: 120rem;
}

#store-name-input {
  width: calc(100% - 10rem);
  max-width: 30rem;
}

#add-store-button {
  max-width: 10rem;
}

.store { border-bottom: 1px solid gray; }
.store:nth-last-of-type(1) { border-bottom: 0; }
</style>
