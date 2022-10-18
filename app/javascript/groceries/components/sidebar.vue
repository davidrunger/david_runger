<template lang='pug'>
aside.border-right.border-gray.overflow-auto
  LoggedInHeader.mb2
  .p2
    form.add-store.flex(@submit.prevent='createStore')
      .flex-1.mr1
        el-input(
          type='text'
          v-model='newStoreName'
          name='newStoreName'
          placeholder='Add a store'
        )
      el-button.flex-0(
        native-type='submit'
        :disabled='postingStore || v$.$invalid'
      ) Add
    .stores-list
      StoreListEntry(
        v-for='store in sortedStores'
        :store='store'
      )
    div(v-if='sortedSpouseStores.length > 0')
      .h2 Spouse's Stores
      .stores-list
        StoreListEntry(
          v-for='store in sortedSpouseStores'
          :store='store'
        )
</template>

<script>
import { mapGetters, mapState } from 'vuex';
import { sortBy } from 'lodash-es';
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';

import LoggedInHeader from './logged_in_header.vue';
import StoreListEntry from './store_list_entry.vue';

export default {
  name: 'Sidebar',

  components: {
    LoggedInHeader,
    StoreListEntry,
  },

  computed: {
    ...mapGetters([
      'currentStore',
    ]),

    ...mapState([
      'postingStore',
      'spouse_stores',
      'stores',
    ]),

    sortedSpouseStores() {
      return sortBy(this.spouse_stores, store => store.name.toLowerCase());
    },

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
    createStore() {
      this.$store.state.postingStore = true;
      const payload = {
        store: {
          name: this.newStoreName,
        },
      };
      this.$http.post(this.$routes.api_stores_path(), { json: payload }).json().
        then(newStoreData => {
          this.newStoreName = '';
          this.$store.state.postingStore = false;
          newStoreData.viewed_at = (new Date(newStoreData.viewed_at)).toISOString();
          this.stores.unshift(newStoreData);
        });
    },
  },

  setup: () => ({ v$: useVuelidate() }),

  validations() {
    return {
      newStoreName: { required },
    };
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
</style>
