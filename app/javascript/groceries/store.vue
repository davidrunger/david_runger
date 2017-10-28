<template lang="pug">
  div.mt1.mb2
    h1.store-name.bold.m-b-1
      span {{ store.name }}
    div.m-b-1
      button(id="show-modal" @click='initializeTripCheckinModal()').
        Check In Shopping Trip
      modal(v-if="showModal")
        slot
          h3.bold.fonst-size-2.m-b-1.
            Uncheck any items you #[i didn't] get.
          ul
            li(v-for='(item, index) in neededItems' :key='item.id')
              input(type='checkbox' v-model='itemsToZero' :value='item' :id='`trip-checkin-item-${item.id}`')
              label(:for='`trip-checkin-item-${item.id}`') {{item.name}}
          div.flex.justify-content-space-between
            button(@click='itemsToZero = []; showModal = false') Cancel
            button(@click='handleTripCheckinModalSubmit') Set checked items to 0 needed
      | &nbsp;
      button(@click='createItemsNeededTextMessage') Text needed items to your phone
      | &nbsp;
      button.copy-to-clipboard Copy needed items to clipboard
      | &nbsp;
      span(v-if='wasCopiedRecently') Copied!
      .spinner--circle(v-if='waitingOnNetwork')

    ul.items-list.mt0.mb0.pl1
      li
        form(@submit='postNewItem')
          input#item-name-input.float-left(type='text' ref='itemName' v-model='newItemName'
            placeholder='Add an item'
          )
          input#add-item-button.button.button-outline.float-left.ml2(type='submit' value='Add')
      Item(v-for='item in sortedItems' :item="item" :key="item.id")
</template>

<script>
import { debounce, sortBy } from 'lodash';
import Clipboard from 'clipboard';

import Item from './item.vue';

export default {
  components: {
    Item,
  },

  data() {
    return {
      itemsToZero: [],
      newItemName: '',
      showModal: false,
      waitingOnNetwork: false,
      wasCopiedRecently: false,
    };
  },

  mounted() {
    const clipboard = new Clipboard('.copy-to-clipboard', {
      text: () => this.neededItems.map(item => `${item.name} (${item.needed})`).join('\n'),
    });
    clipboard.on('success', () => {
      this.wasCopiedRecently = true;
      setTimeout(() => { this.wasCopiedRecently = false; }, 3000);
    });
  },

  computed: {
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
      });
    },

    deleteItem(item) {
      this.$http.delete(this.$routes.api_item_path(item.id));
      this.store.items = this.store.items.filter(otherItem => otherItem.id !== item.id);
    },

    handleTripCheckinModalSubmit() {
      this.$store.dispatch('zeroItems', this.itemsToZero.slice());
      this.itemsToZero = [];
      this.showModal = false;
    },

    initializeTripCheckinModal() {
      this.itemsToZero = this.neededItems;
      this.showModal = true;
    },

    setNeeded(item, needed) {
      this.$set(this, 'waitingOnNetwork', true);
      item.needed = needed;
      this.debouncedPatchItem(item.id, item.needed);
    },

    // we need `function` for correct `this`
    // eslint-disable-next-line func-names
    debouncedPatchItem: debounce(function (itemId, newNeeded) {
      const payload = {
        item: { needed: newNeeded },
      };
      this.$http.patch(this.$routes.api_item_path(itemId), payload).then(() => {
        this.$set(this, 'waitingOnNetwork', false);
      });
    }, 500),

    postNewItem(event) {
      event.preventDefault();
      this.$set(this, 'waitingOnNetwork', true);
      const payload = {
        item: {
          name: this.newItemName,
        },
      };
      this.$http.post(this.$routes.api_store_items_path(this.store.id), payload).then(response => {
        this.newItemName = '';
        this.$set(this, 'waitingOnNetwork', false);
        this.store.items.unshift({ createdAt: (new Date()).valueOf(), ...response.data });
      });
    },

    sortItems(items) {
      return sortBy(items, item => item.name.toLowerCase());
    },
  },

  props: [
    'store',
  ],
};
</script>

<style scoped>
h1 { font-size: 22px; }

#needed {
  margin-bottom: 20px;
}

.spinner--circle {
  margin-left: 8px;
  display: inline-block;
  height: 14px;
  width: 14px;
}

.add-item-button { text-align: text-bottom; }
</style>
