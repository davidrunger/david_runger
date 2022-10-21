<template lang='pug'>
aside.border-right.border-gray(
  :class='{ collapsed: !visible }'
)
  .overflow-auto.dvh-100.hidden-scrollbars
    .sidebar-toggle__container.border-bottom
      button.sidebar-toggle(
        @click='this.visible = !visible'
        :class='{ "rotated-180": visible }'
      )
        arrow-bar-right-icon(size='29')
    nav
      .store-lists-container.pb2
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
          .spouse-stores-header.h2 Spouse's Stores
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
import { ArrowBarRightIcon } from 'vue-tabler-icons';

import { on } from '@/lib/event_bus';
import LoggedInHeader from './logged_in_header.vue';
import StoreListEntry from './store_list_entry.vue';

export default {
  name: 'Sidebar',

  components: {
    ArrowBarRightIcon,
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

  created() {
    this.unsubscribeFromStoreSelected = on('groceries:store-selected', this.handleStoreSelected);
  },

  unmounted() {
    this.unsubscribeFromStoreSelected();
  },

  data() {
    return {
      newStoreName: '',
      visible: !this.$is_mobile_device,
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

    handleStoreSelected() {
      if (this.$is_mobile_device) {
        this.visible = false;
      }
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
  transition: min-width 0.7s, width 0.7s, max-width 0.7s;

  .spouse-stores-header,
  :deep(.stores-list__item) {
    opacity: 1;
    transition: opacity 0.7s;
  }

  &.collapsed {
    min-width: 50px;
    width: 50px;
    max-width: 50px;

    .spouse-stores-header,
    :deep(.stores-list__item) {
      opacity: 0.3;
    }

    .overflow-auto {
      overflow-x: hidden;
    }
  }

  &:not(.collapsed) {
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
}

nav {
  position: relative;
  top: 10px;

  @media screen and (max-width: 399px) {
    min-width: calc(150px - var(--space-2) * 2);
    width: calc(45vw - var(--space-2) * 2);
    max-width: calc(180px - var(--space-2) * 2);
  }

  @media screen and (min-width: 400px) {
    min-width: calc(180px - var(--space-2) * 2);
    width: calc(35vw - var(--space-2) * 2);
    max-width: calc(280px - var(--space-2) * 2);
  }
}

.store-lists-container {
  position: relative;
  left: var(--space-2);
}

.sidebar-toggle__container {
  position: sticky;
  top: 0;
  height: 50px;
  z-index: 4;
  background: linear-gradient(to bottom, #458fc0 0%, #4f92c1 100%);
  border-color: #43789d;
}

button.sidebar-toggle {
  position: absolute;
  right: 0;
  margin-bottom: 8px;
  background: none;
  color: inherit;
  border: none;
  padding: 0;
  font: inherit;
  cursor: pointer;
  outline: inherit;
  height: 50px;
  width: 50px;
  transition: transform 0.7s, left 0.7s;

  &.rotated-180 {
    @media screen and (max-width: 399px) {
      transform: rotate(180deg);
    }

    @media screen and (min-width: 400px) {
      transform: rotate(180deg);
    }
  }
}
</style>
