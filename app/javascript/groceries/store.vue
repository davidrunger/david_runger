<template lang="pug">
  div.mt1.mb2
    h1.store-name.bold.xs-mb20
      span {{ store.name }}
      .spinner--circle(v-if='waitingOnNetwork')

    #needed
      h2.font-size-20
        span Needed
        button.copy-to-clipboard Copy list to clipboard
        <span v-if='wasCopiedRecently'>Copied!</span>
      ul.items-list.mt0.mb0.pl1
        li
          form(v-on:submit='postNewItem')
            input#item-name-input.float-left(type='text' ref='itemName' v-model='newItemName'
              placeholder='Add an item'
            )
            input#add-item-button.button.button-outline.float-left.ml2(type='submit' value='Add')
        Item(v-for='item in neededItems' :item="item" :key="item.id")

    #purchased(v-if='purchasedItems.length > 0')
      h2.font-size-20 Purchased
      ul.items-list.mt0.mb0.pl1
        Item(v-for='item in purchasedItems' :item="item" :key="item.id")
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
      waitingOnNetwork: false,
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
    neededItems() {
      let { items } = this.store;
      items = items.filter(item => item.needed > 0);
      items = sortBy(items, item => item.name.toLowerCase());
      return items;
    },

    purchasedItems() {
      let { items } = this.store;
      items = items.filter(item => item.needed === 0);
      items = sortBy(items, item => item.name.toLowerCase());
      return items;
    },
  },

  methods: {
    logDoubleClick() {
      console.log('double clicked!');
    },

    deleteItem(item) {
      this.$http.delete(`api/items/${item.id}`);
      this.store.items = this.store.items.filter(otherItem => otherItem.id !== item.id);
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
      this.$http.patch(`api/items/${itemId}`, payload).then(() => {
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
      this.$http.post(`api/stores/${this.store.id}/items`, payload).then(response => {
        this.newItemName = '';
        this.$set(this, 'waitingOnNetwork', false);
        this.store.items.unshift(response.data);
      });
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
