<template lang="pug">
aside.border-r.border-neutral-400(
  :class='{ collapsed }'
)
  .overflow-auto.dvh-100.hidden-scrollbars
    .sidebar-toggle__container.border-b
      button.sidebar-toggle(
        @click='collapsed = !collapsed'
        :class='{ "rotated-180": expanded }'
      )
        arrow-bar-right-icon(size='29')
    LoggedInHeader.mb-2
    nav
      .store-lists-container.pb-4
        form.add-store.flex(@submit.prevent='handleNewStoreSubmission()')
          .flex-1.mr-2
            el-input(
              type='text'
              v-model='newStoreName'
              name='newStoreName'
              placeholder='Add a store'
            )
          el-button(
            native-type='submit'
            :disabled='postingStore || v$.$invalid'
          ) Add
        .stores-list
          StoreListEntry(
            v-for='store in groceriesStore.sortedStores'
            :store='store'
          )
        div(v-if='groceriesStore.sortedSpouseStores.length > 0')
          .spouse-stores-header.text-2xl Spouse's Stores
          .stores-list
            StoreListEntry(
              v-for='store in groceriesStore.sortedSpouseStores'
              :store='store'
            )
</template>

<script lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { mapState } from 'pinia';
import { defineComponent, inject, ref } from 'vue';
import { ArrowBarRightIcon } from 'vue-tabler-icons';

import { useGroceriesStore } from '@/groceries/store';
import { useSubscription } from '@/lib/composables/use_subscription';

import LoggedInHeader from './LoggedInHeader.vue';
import StoreListEntry from './StoreListEntry.vue';

export default defineComponent({
  name: 'Sidebar',

  components: {
    ArrowBarRightIcon,
    LoggedInHeader,
    StoreListEntry,
  },

  computed: {
    ...mapState(useGroceriesStore, ['postingStore', 'spouse_stores']),

    expanded(): boolean {
      return !this.collapsed;
    },
  },

  setup() {
    const isMobileDevice = inject('isMobileDevice');
    const collapsed = ref(isMobileDevice);

    function handleStoreSelected() {
      if (isMobileDevice) {
        collapsed.value = true;
      }
    }

    useSubscription('groceries:store-selected', handleStoreSelected);

    return {
      collapsed,
      groceriesStore: useGroceriesStore(),
      v$: useVuelidate(),
    };
  },

  data() {
    return {
      newStoreName: '',
    };
  },

  methods: {
    async handleNewStoreSubmission() {
      await this.groceriesStore.createStore(this.newStoreName);
      this.newStoreName = '';
    },
  },

  validations() {
    return {
      newStoreName: { required },
    };
  },
});
</script>

<style lang="scss" scoped>
/* stylelint-disable-next-line length-zero-no-unit */
@mixin sidebar-width($padding: 0px) {
  @media screen and (width <= 400px) {
    min-width: calc(150px - $padding);
    width: calc(45vw - $padding);
    max-width: calc(180px - $padding);
  }

  @media screen and (width >= 400px) {
    min-width: calc(180px - $padding);
    width: calc(35vw - $padding);
    max-width: calc(280px - $padding);
  }
}

aside {
  background: linear-gradient(to bottom, #458fc0 0%, #a8b2ce 50%, #b6bcd5 100%);
  transition:
    min-width 0.7s,
    width 0.7s,
    max-width 0.7s;

  @include sidebar-width;

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
}

:deep(.el-sub-menu__title) {
  @include sidebar-width;
}

nav {
  position: relative;
  top: 10px;

  @include sidebar-width($padding: 32px);
}

.store-lists-container {
  position: relative;
  left: 16px;
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
  transition:
    transform 0.7s,
    left 0.7s;

  &.rotated-180 {
    transform: rotate(180deg);
  }
}
</style>
