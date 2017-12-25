<template lang="pug">
div.mt1.mb2.ml3.mr2
  h2.h2.store-name.bold.my2
    span {{ store.name }}
    span.spinner--circle.ml1(v-if='debouncingOrWaitingOnNetwork')
  div.mb2
    el-button(id="show-modal" @click='initializeTripCheckinModal()' size='mini').
      Check In Shopping Trip
    el-button(@click='createItemsNeededTextMessage' size='mini') Text items to phone
    el-button.copy-to-clipboard(size='mini') Copy to clipboard
    span(v-if='wasCopiedRecently') Copied!

  vue-form.col-5.flex(@submit.prevent='postNewItem' :state='formstate')
    validate.flex-1.float-left
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

  modal(v-if="showModal" width='85%', maxWidth='400px')
    slot
      h3.bold.fonst-size-2.mb2.
        What did you get?
      ul
        li.flex.items-center.mb1(v-for='(item, index) in neededItems' :key='item.id')
          input(type='checkbox' v-model='itemsToZero' :value='item' :id='`trip-checkin-item-${item.id}`')
          label.ml1(:for='`trip-checkin-item-${item.id}`') {{item.name}}
      div.flex.justify-around.mt2
        el-button(
          @click='handleTripCheckinModalSubmit'
          type='primary'
          plain
        ) Set checked items to 0 needed
        el-button(
          @click="$store.commit('setShowModal', { value: false })"
          type='text'
        ) Cancel
</template>

<script>
import { mapGetters, mapState } from 'vuex';
import { debounce, sortBy } from 'lodash';
import Clipboard from 'clipboard';

import Item from './item.vue';

export default {
  components: {
    Item,
  },

  data() {
    return {
      formstate: {},
      itemsToZero: [],
      newItemName: '',
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
    ...mapGetters([
      'debouncingOrWaitingOnNetwork',
    ]),

    ...mapState([
      'showModal',
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
      });
    },

    handleTripCheckinModalSubmit() {
      this.$store.dispatch('zeroItems', { items: this.itemsToZero.slice() });
      this.itemsToZero = [];
      this.$store.commit('setShowModal', { value: false });
    },

    initializeTripCheckinModal() {
      this.itemsToZero = this.neededItems;
      this.$store.commit('setShowModal', { value: true });
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
    }, 500),

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
  },

  props: [
    'store',
  ],
};
</script>

<style scoped>
.item-name-input {
  max-width: 230px;
}

.spinner--circle {
  height: 14px;
  width: 14px;
}
</style>
