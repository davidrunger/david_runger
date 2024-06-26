<template lang="pug">
.store-container.overflow-auto.hidden-scrollbars.pt-2.pb-4.pl-8.pr-4
  h2.store-name.my-4
    input(
      v-if='editingName'
      type='text'
      v-model='store.name'
      @blur='stopEditingAndUpdateStoreName()'
      @keydown.enter='stopEditingAndUpdateStoreName()'
      ref='store-name-input'
    )
    span(v-if='!editingName') {{ store.name }}
    a.edit-store.js-link.text-neutral-400.ml-2(@click='editStoreName')
      edit-icon(size='27')
    span(v-if='store.own_store')
      el-button.ml-2(v-if='store.private' size='small' @click='togglePrivacy') Make public
      el-button.ml-2(v-else size='small' @click='togglePrivacy') Make private
    span.spinner--circle.ml-2(v-if='debouncingOrWaitingOnNetwork')
  div.buttons-container.mb-4
    el-button.mr-2.mt-2(
      id="show-modal"
      @click='initializeTripCheckIn'
      :size='$is_mobile_device ? "small" : null'
    ) Check in items

  div.mb-2
    el-input(
      v-if='editingNotes'
      type='textarea'
      placeholder='Member phone number: 619-867-5309'
      v-model='store.notes'
      @blur='stopEditingAndUpdateStoreNotes()'
      ref='store-notes-input'
    )
    p.whitespace-pre-wrap(v-else)
      | {{store.notes || 'No notes yet'}}
      a.edit-store.js-link.text-neutral-400.ml-2(v-if='store.own_store' @click='editStoreNotes')
        edit-icon(size='18')

  form.flex(v-if='store.own_store' @submit.prevent='postNewItem')
    .float-left
      el-input.item-name-input(
        placeholder='Add an item'
        type='text'
        v-model='newItemName'
        name='newItemName'
      )
    .ml-2
      el-button.button.button-outline(
        native-type='submit'
        :disabled='v$.$invalid'
      ) Add

  .items-list.mt-0.mb-0
    Item(
      v-for='item in sortedItems'
      :item="item"
      :key="item.id"
      :ownStore='store.own_store'
    )

  Modal(name='check-in-shopping-trip' width='85%' maxWidth='400px')
    slot
      .flex.items-center.mb-3
        span Stores: {{checkInStoreNames}}
        el-button.choose-stores.ml-2(
          link
          type='primary'
          @click='manageCheckInStores'
        ) Choose stores

      CheckInItemsList(
        title="Needed"
        :items="neededUnskippedCheckInItemsNotInCart"
      )

      CheckInItemsList(
        title="In Cart"
        :items="neededUnskippedCheckInItemsInCart"
      )

      CheckInItemsList(
        title="Skipped"
        :items="neededSkippedCheckInItems"
      )

      div.flex.justify-around.mt-4

        el-button(
          @click="modalStore.hideModal({ modalName: 'check-in-shopping-trip' })"
          type='primary'
          link
        ) Cancel

        el-button(
          @click='handleTripCheckinModalSubmit'
          type='primary'
          plain
        ) Check in items in cart

  Modal(name='manage-check-in-stores' width='80%' maxWidth='370px')
    slot
      h4.font-bold.mt-2.mb-4.
        Which stores would you like to check in?
      CheckInStoreList(
        :stores='groceriesStore.sortedStores'
      )
      h4.font-bold.mb-4.
        Spouse's stores
      CheckInStoreList(
        :stores='groceriesStore.sortedSpouseStores'
      )
      div.flex.justify-around.mt-4
        el-button(
          @click="modalStore.hideModal({ modalName: 'manage-check-in-stores' })"
          type='primary'
        ) Done
</template>

<script lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { mapState } from 'pinia';
import Toastify from 'toastify-js';
import { defineComponent, PropType } from 'vue';
import { EditIcon } from 'vue-tabler-icons';

import { helpers, useGroceriesStore } from '@/groceries/store';
import { Item as ItemType, Store } from '@/groceries/types';
import { useModalStore } from '@/shared/modal/store';

import CheckInItemsList from './check_in_items_list.vue';
import CheckInStoreList from './check_in_store_list.vue';
import Item from './item.vue';

export default defineComponent({
  components: {
    CheckInItemsList,
    CheckInStoreList,
    EditIcon,
    Item,
  },

  computed: {
    ...mapState(useGroceriesStore, [
      'debouncingOrWaitingOnNetwork',
      'itemsInCart',
      'neededSkippedCheckInItems',
      'neededUnskippedCheckInItemsInCart',
      'neededUnskippedCheckInItemsNotInCart',
    ]),

    checkInStoreNames(): string {
      return this.groceriesStore.checkInStores
        .map((store: Store) => store.name)
        .join(', ');
    },

    sortedItems(): ItemType[] {
      return helpers.sortByName(this.store.items);
    },
  },

  data() {
    return {
      editingName: false,
      editingNotes: false,
      groceriesStore: useGroceriesStore(),
      modalStore: useModalStore(),
      newItemName: '',
    };
  },

  methods: {
    editStoreName() {
      this.editingName = true;
      // wait a tick for input to render, then focus it
      setTimeout(this.focusStoreNameInput);
    },

    editStoreNotes() {
      this.editingNotes = true;
      // wait a tick for input to render, then focus it
      setTimeout(this.focusStoreNotesInput);
    },

    focusStoreNameInput(callsAlready = 0) {
      if (!this.editingName) return;

      const storeNameInput = this.$refs['store-name-input'] as HTMLInputElement;
      if (storeNameInput) {
        storeNameInput.focus();
      } else if (callsAlready < 20) {
        // the storeNameInput hasn't had time to render yet; retry later
        setTimeout(() => {
          this.focusStoreNameInput(callsAlready + 1);
        }, 50);
      }
    },

    focusStoreNotesInput(callsAlready = 0) {
      if (!this.editingNotes) return;

      const storeNotesInput = this.$refs[
        'store-notes-input'
      ] as HTMLInputElement;
      if (storeNotesInput) {
        storeNotesInput.focus();
      } else if (callsAlready < 20) {
        // the storeNotesInput hasn't had time to render yet; retry later
        setTimeout(() => {
          this.focusStoreNotesInput(callsAlready + 1);
        }, 50);
      }
    },

    handleTripCheckinModalSubmit() {
      this.groceriesStore.zeroItemsInCart();
      this.modalStore.hideModal({ modalName: 'check-in-shopping-trip' });
    },

    initializeTripCheckIn() {
      this.groceriesStore.addCheckInStore({
        store: this.groceriesStore.currentStore as Store,
      });
      this.modalStore.showModal({ modalName: 'check-in-shopping-trip' });
    },

    manageCheckInStores() {
      this.modalStore.showModal({ modalName: 'manage-check-in-stores' });
    },

    postNewItem() {
      this.groceriesStore
        .createItem({
          store: this.store,
          itemAttributes: {
            name: this.newItemName,
          },
        })
        .catch(async ({ response }: { response: Response }) => {
          this.groceriesStore.decrementPendingRequests();
          const { errors } = await response.json();
          for (const errorMessage of errors) {
            Toastify({
              text: errorMessage,
              className: 'error',
              position: 'center',
              duration: 2500,
            }).showToast();
          }
        });
      this.newItemName = '';
    },

    stopEditingAndUpdateStoreName() {
      this.editingName = false;
      this.groceriesStore.updateStore({
        store: this.store,
        attributes: {
          name: this.store.name,
        },
      });
    },

    stopEditingAndUpdateStoreNotes() {
      this.editingNotes = false;
      this.groceriesStore.updateStore({
        store: this.store,
        attributes: {
          notes: this.store.notes,
        },
      });
    },

    togglePrivacy() {
      this.groceriesStore.updateStore({
        store: this.store,
        attributes: {
          private: !this.store.private,
        },
      });
    },
  },

  props: {
    store: {
      type: Object as PropType<Store>,
      required: true,
    },
  },

  setup: () => ({ v$: useVuelidate() }),

  validations() {
    return {
      newItemName: { required },
    };
  },
});
</script>

<style lang="scss" scoped>
button.choose-stores {
  font-size: inherit;
  padding: 0;
  position: relative;
  top: -0.5px;
}

// https://stackoverflow.com/a/30891910/4009384
.buttons-container {
  margin-top: calc(-1 * var(--space-1));
}

.store-container {
  max-height: 97vh; // fallback for browsers that don't yet support `dvh` units
  max-height: 97dvh;
}

.item-name-input {
  max-width: 230px;
}

.spinner--circle {
  height: 14px;
  width: 14px;
}

.edit-store {
  &:hover {
    color: black;
  }
}

.check-in-items-list {
  max-height: 50vh;
  overflow: auto;
}
</style>
