<template lang="pug">
div.mt1.mb2.ml3.mr2
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
      i.el-icon-edit-outline.font-size-2
    span.spinner--circle.ml1(v-if='debouncingOrWaitingOnNetwork')
  div.mb2
    el-button(id="show-modal" @click='initializeTripCheckinModal()' size='mini').
      Check in shopping trip
    el-button(@click='handleTextItemsToPhoneClick' size='mini') Text items to phone
    el-button.copy-to-clipboard(size='mini') Copy to clipboard
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
      a.edit-store.js-link.gray.ml1(@click='editStoreNotes')
        i.el-icon-edit-outline

  vue-form.col-5.flex(@submit.prevent='postNewItem' :state='formstate')
    validate.float-left
      el-input.item-name-input(
        placeholder='Add an item'
        type='text'
        v-model='newItemName'
        name='newItemName'
        required
        size='medium'
      )
    el-input.flex-0.button.button-outline.float-left.ml1(
      value='Add'
      type='submit'
      size='medium'
      :disabled='formstate.$invalid'
    )

  ul.items-list.mt0.mb0
    Item(v-for='item in sortedItems' :item="item" :key="item.id")

  Modal(name='check-in-shopping-trip' width='85%' maxWidth='400px')
    slot
      h3.bold.mb2.
        What did you get?
      ul
        li.flex.items-center.mb1(v-for='(item, index) in neededItems' :key='item.id')
          input(
            type='checkbox'
            v-model='itemsToZero'
            :value='item'
            :id='`trip-checkin-item-${item.id}`'
          )
          label.ml1(:for='`trip-checkin-item-${item.id}`') {{item.name}}
      div.flex.justify-around.mt2
        el-button(
          @click='handleTripCheckinModalSubmit'
          type='primary'
          plain
        ) Set checked items to 0 needed
        el-button(
          @click="$store.commit('hideModal', { modalName: 'check-in-shopping-trip' })"
          type='text'
        ) Cancel

  NeedPhoneNumberModal(@send-text-message='createItemsNeededTextMessage')
</template>

<script>
import { mapGetters, mapState } from 'vuex';
import { debounce, get, isEmpty, sortBy } from 'lodash';
import ClipboardJS from 'clipboard';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';

import { DEBOUNCE_TIME } from 'groceries/constants';
import Item from './item.vue';
import NeedPhoneNumberModal from './need_phone_number_modal.vue';

export default {
  components: {
    Item,
    NeedPhoneNumberModal,
  },

  data() {
    return {
      editingName: false,
      editingNotes: false,
      formstate: {},
      itemsToZero: [],
      newItemName: '',
      wasCopiedRecently: false,
    };
  },

  mounted() {
    const clipboard = new ClipboardJS('.copy-to-clipboard', {
      text: () => this.neededItems.map(item => `${item.name} (${item.needed})`).join('\n'),
    });
    clipboard.on('success', () => {
      this.wasCopiedRecently = true;
      setTimeout(() => { this.wasCopiedRecently = false; }, 3000);
    });
  },

  computed: {
    ...mapGetters([
      'debouncingOrWaitingOnNetwork',
    ]),

    ...mapState([
      'current_user',
    ]),

    neededItems() {
      return this.sortItems(this.store.items.filter(item => item.needed > 0));
    },

    sortedItems() {
      return this.sortItems(this.store.items);
    },
  },

  methods: {
    createItemsNeededTextMessage() {
      this.$http.post(this.$routes.api_text_messages_path(), {
        text_message: {
          message_type: 'grocery_store_items_needed',
          message_params: { store_id: this.store.id },
        },
      }).then((response) => {
        if (response.status === 201) {
          Toastify({
            text: 'Message sent!',
            className: 'success',
            position: 'center',
            duration: 2500,
          }).showToast();
        }
      }).catch((error) => {
        const errorMessage = get(error, 'response.data.error', 'Something went wrong');
        Toastify({
          text: errorMessage,
          className: 'error',
          position: 'center',
          duration: 2500,
        }).showToast();
      });
    },

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

      const storeNameInput = this.$refs['store-name-input'];
      if (storeNameInput) {
        storeNameInput.focus();
      } else if (callsAlready < 20) {
        // the storeNameInput hasn't had time to render yet; retry later
        setTimeout(() => { this.focusStoreNameInput(callsAlready + 1); }, 50);
      }
    },

    focusStoreNotesInput(callsAlready = 0) {
      if (!this.editingNotes) return;

      const storeNotesInput = this.$refs['store-notes-input'];
      if (storeNotesInput) {
        storeNotesInput.focus();
      } else if (callsAlready < 20) {
        // the storeNotesInput hasn't had time to render yet; retry later
        setTimeout(() => { this.focusStoreNotesInput(callsAlready + 1); }, 50);
      }
    },

    handleTripCheckinModalSubmit() {
      this.$store.dispatch('zeroItems', { items: this.itemsToZero.slice() });
      this.itemsToZero = [];
      this.$store.commit('hideModal', { modalName: 'check-in-shopping-trip' });
    },

    handleTextItemsToPhoneClick() {
      const currentUserPhone = this.current_user.phone;
      if (isEmpty(currentUserPhone)) {
        this.$store.commit('showModal', { modalName: 'set-phone-number' });
      } else {
        this.createItemsNeededTextMessage();
      }
    },

    initializeTripCheckinModal() {
      this.itemsToZero = this.neededItems;
      this.$store.commit('showModal', { modalName: 'check-in-shopping-trip' });
    },

    // we need `function` for correct `this`
    // eslint-disable-next-line func-names
    debouncedPatchItem: debounce(function (itemId, newNeeded) {
      const payload = {
        item: { needed: newNeeded },
      };
      this.$http.patch(this.$routes.api_item_path(itemId), payload).then(() => {
        this.$store.commit('decrementPendingRequests');
      });
    }, DEBOUNCE_TIME),

    postNewItem() {
      if (this.formstate.$invalid) return;

      this.$store.commit('incrementPendingRequests');
      const payload = {
        item: {
          name: this.newItemName,
        },
      };
      this.$http.post(this.$routes.api_store_items_path(this.store.id), payload).then(response => {
        this.newItemName = '';
        this.$store.commit('decrementPendingRequests');
        this.store.items.unshift({ createdAt: (new Date()).valueOf(), ...response.data });
      });
    },

    sortItems(items) {
      return sortBy(items, item => item.name.toLowerCase());
    },

    stopEditingAndUpdateStoreName() {
      this.editingName = false;
      this.$store.dispatch('updateStore', {
        id: this.store.id,
        attributes: {
          name: this.store.name,
        },
      });
    },

    stopEditingAndUpdateStoreNotes() {
      this.editingNotes = false;
      this.$store.dispatch('updateStore', {
        id: this.store.id,
        attributes: {
          notes: this.store.notes,
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
};
</script>

<style lang='scss' scoped>
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
</style>

<style lang='scss'>
.toastify {
  &.error {
    background: #d42b2b;
  }

  &.success {
    background: #219b21;
  }
}

// double the `.toastify-center` class to ensure it has higher precedence than the library's CSS
.toastify-center.toastify-center {
  left: inherit;
  right: 50%;
  transform: translateX(50%);
}

.pre-wrap {
  white-space: pre-wrap;
}
</style>
