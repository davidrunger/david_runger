<template lang="pug">
.store-container.overflow-auto.hidden-scrollbars.pt1.pb2.pl3.pr2
  h2.h2.store-name.bold.my2
    input(
      v-if='editingName'
      type='text'
      v-model='store.name'
      @blur='stopEditingAndUpdateStoreName()'
      @keydown.enter='stopEditingAndUpdateStoreName()'
      ref='store-name-input'
    )
    span(v-if='!editingName') {{ store.name }}
    a.edit-store.js-link.gray.ml1(@click='editStoreName')
      edit-icon(size='27')
    span(v-if='store.own_store')
      el-button.ml1(v-if='store.private' size='small' @click='togglePrivacy') Make public
      el-button.ml1(v-else size='small' @click='togglePrivacy') Make private
    span.spinner--circle.ml1(v-if='debouncingOrWaitingOnNetwork')
  div.buttons-container.mb2
    el-button.mr1.mt1(
      id="show-modal"
      @click='initializeTripCheckIn'
      :size='$is_mobile_device ? "small" : null'
    ) Check in items
    el-button.copy-to-clipboard.mt1(
      :size='$is_mobile_device ? "small" : null'
    ) Copy to clipboard
    span(v-if='wasCopiedRecently') Copied!

  div.mb1
    h3.h3 Notes
    el-input(
      v-if='editingNotes'
      type='textarea'
      placeholder='Member phone number: 619-867-5309'
      v-model='store.notes'
      @blur='stopEditingAndUpdateStoreNotes()'
      ref='store-notes-input'
    )
    p.pre-wrap(v-else)
      | {{store.notes || 'No notes yet'}}
      a.edit-store.js-link.gray.ml1(v-if='store.own_store' @click='editStoreNotes')
        edit-icon(size='18')

  form.flex(v-if='store.own_store' @submit.prevent='postNewItem')
    .float-left
      el-input.item-name-input(
        placeholder='Add an item'
        type='text'
        v-model='newItemName'
        name='newItemName'
      )
    .ml1
      el-button.flex-0.button.button-outline(
        native-type='submit'
        :disabled='v$.$invalid'
      ) Add

  .items-list.mt0.mb0
    Item(
      v-for='item in sortedItems'
      :item="item"
      :key="item.id"
      :ownStore='store.own_store'
    )

  Modal(name='check-in-shopping-trip' width='85%' maxWidth='400px')
    slot
      div
        span Stores: {{checkInStoreNames}}
        el-button.choose-stores.ml1(
          link
          type='primary'
          @click='manageCheckInStores'
        ) Choose stores
      h3.bold.mb2.
        What did you get? ({{itemsToZero.length}}/{{neededCheckInItems.length}})
      ul.check-in-items-list
        li.flex.items-center.mb1(
          v-for='(item, index) in neededCheckInItems'
          :key='item.id'
        )
          input(
            type='checkbox'
            v-model='itemsToZero'
            :value='item'
            :id='`trip-checkin-item-${item.id}`'
          )
          label.ml1(:for='`trip-checkin-item-${item.id}`')
            span {{item.name}}
            span(v-if='item.needed > 1') {{' '}} ({{item.needed}})
            el-button(
              link
              type='primary'
              @click='skip(item)'
            ) Skip
      div.flex.justify-around.mt2
        el-button(
          @click='handleTripCheckinModalSubmit'
          type='primary'
          plain
        ) Set checked items to 0 needed
        el-button(
          @click="modalStore.hideModal({ modalName: 'check-in-shopping-trip' })"
          type='primary'
          link
        ) Cancel

  Modal(name='manage-check-in-stores' width='80%' maxWidth='370px')
    slot
      h4.bold.mt1.mb2.
        Which stores would you like to check in?
      CheckInStoreList(
        :stores='groceriesStore.sortedStores'
      )
      h4.bold.mb2.
        Spouse's stores
      CheckInStoreList(
        :stores='groceriesStore.sortedSpouseStores'
      )
      div.flex.justify-around.mt2
        el-button(
          @click="modalStore.hideModal({ modalName: 'manage-check-in-stores' })"
          type='primary'
        ) Done
</template>

<script lang='ts'>
import { defineComponent } from 'vue';
import { mapState, StoreDefinition } from 'pinia';
import ClipboardJS from 'clipboard';
import { EditIcon } from 'vue-tabler-icons';
import { required } from '@vuelidate/validators';
import { useVuelidate } from '@vuelidate/core';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';
import { useGroceriesStore, helpers } from '@/groceries/store';
import { useModalStore } from '@/shared/modal/store';
import { Item as ItemType, Store } from '@/groceries/types';
import CheckInStoreList from './check_in_store_list.vue';
import Item from './item.vue';

export default defineComponent({
  components: {
    CheckInStoreList,
    EditIcon,
    Item,
  },

  computed: {
    ...mapState(useGroceriesStore as StoreDefinition, [
      'debouncingOrWaitingOnNetwork',
      'neededCheckInItems',
    ]),

    checkInStoreNames(): string {
      return this.groceriesStore.checkInStores.map((store: Store) => store.name).join(', ');
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
      itemsToZero: [],
      modalStore: useModalStore(),
      newItemName: '',
      wasCopiedRecently: false,
    };
  },

  mounted() {
    const clipboard = new ClipboardJS('.copy-to-clipboard', {
      text: () => {
        // ensure that the current store is in the checkInStores
        this.groceriesStore.addCheckInStore({ store: this.store });

        return this.neededCheckInItems.
          map((item: ItemType) => `${item.name} (${item.needed})`).
          join('\n');
      },
    });
    clipboard.on('success', () => {
      this.wasCopiedRecently = true;
      setTimeout(() => { this.wasCopiedRecently = false; }, 3000);
    });
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
        setTimeout(() => { this.focusStoreNameInput(callsAlready + 1); }, 50);
      }
    },

    focusStoreNotesInput(callsAlready = 0) {
      if (!this.editingNotes) return;

      const storeNotesInput = this.$refs['store-notes-input'] as HTMLInputElement;
      if (storeNotesInput) {
        storeNotesInput.focus();
      } else if (callsAlready < 20) {
        // the storeNotesInput hasn't had time to render yet; retry later
        setTimeout(() => { this.focusStoreNotesInput(callsAlready + 1); }, 50);
      }
    },

    handleTripCheckinModalSubmit() {
      this.groceriesStore.zeroItems({
        items:
          this.itemsToZero.slice().
            filter(item => this.groceriesStore.neededCheckInItems.includes(item)),
      });
      this.itemsToZero = [];
      this.modalStore.hideModal({ modalName: 'check-in-shopping-trip' });
    },

    initializeTripCheckIn() {
      this.groceriesStore.addCheckInStore({ store: this.groceriesStore.currentStore });
      this.modalStore.showModal({ modalName: 'check-in-shopping-trip' });
    },

    manageCheckInStores() {
      this.modalStore.showModal({ modalName: 'manage-check-in-stores' });
    },

    postNewItem() {
      this.groceriesStore.createItem({
        store: this.store,
        itemAttributes: {
          name: this.newItemName,
        },
      }).catch(async ({ response }: { response: Response }) => {
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

    skip(item: ItemType) {
      this.groceriesStore.skipItem({ item });
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
      type: Object,
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

<style lang='scss' scoped>
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

// repeat class to increase specificity to override element plus default margin-left
.copy-to-clipboard.copy-to-clipboard {
  margin-left: 0;
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
