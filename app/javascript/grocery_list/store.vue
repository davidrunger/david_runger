  <template lang="pug">
  div.mt1.mb2
    h1.store-name.h2.blue-medium
      span {{ store.name }}
      .spinner--circle(v-if='itemChangeUnsaved')

    form(v-on:submit='postNewItem')
      input#item-name-input.float-left(type='text' ref='itemName' v-model='newItemName'
        placeholder='Add an item'
      )
      input#add-item-button.button.button-outline.float-left.ml2(type='submit' value='Add')

    #needed
      h2.font-size-20
        span Needed
        button.copy-to-clipboard Copy to clipboard
        <span v-if='wasCopiedRecently'>Copied!</span>
      ul.list-reset.mt0.mb0.pl1
        li.blue-dark(v-if='postingItem') Saving ...
        li(v-for='item in neededItems')
          | {{item.name}}
          | ({{item.needed}})
          span.increment.h2.js-link(v-on:click='setNeeded(item, item.needed + 1)') +
          span.decrement.h2.pl1.pr1.js-link(v-on:click='setNeeded(item, item.needed - 1)') &ndash;
          span.purchase.h2.pl1.pr1.js-link(v-on:click='setNeeded(item, 0)') ✓
          span.delete.h2.pl1.pr1.js-link(v-on:click='deleteItem(item)') ×

    #purchased
      h2.font-size-20 Purchased
      ul.list-reset.mt0.mb0.pl1
        li.blue-dark(v-if='postingItem') Saving ...
        li(v-for='item in purchasedItems')
          | {{item.name}}
          | ({{item.needed}})
          span.increment.h2.js-link(v-on:click='setNeeded(item, item.needed + 1)') +
          span.decrement.h2.pl1.pr1.js-link(v-on:click='setNeeded(item, item.needed - 1)') &ndash;
          span.purchase.h2.pl1.pr1.js-link(v-on:click='setNeeded(item, 0)') ✓
          span.delete.h2.pl1.pr1.js-link(v-on:click='deleteItem(item)') ×
</template>

<script>
import { debounce, sortBy } from 'lodash';
import Clipboard from 'clipboard';

export default {
  data() {
    return {
      itemChangeUnsaved: false,
      postingItem: false,
      newItemName: '',
      wasCopiedRecently: false,
    };
  },

  mounted() {
    const clipboard = new Clipboard('.copy-to-clipboard', {
      text: () => this.neededItems.map(item => `${item.name} (${item.needed})`).join('\n')
    });
    clipboard.on('success', () => {
      this.wasCopiedRecently = true;
      setTimeout(() => this.wasCopiedRecently = false, 3000);
    });
  },

  computed: {
    neededItems() {
      let items = this.store.items;
      items = items.filter(item => item.needed > 0)
      items = sortBy(items, item => item.name.toLowerCase());
      return items;
    },

    purchasedItems() {
      let items = this.store.items;
      items = items.filter(item => item.needed === 0)
      items = sortBy(items, item => item.name.toLowerCase());
      return items;
    }
  },

  methods: {
    deleteItem(item) {
      this.$http.delete(`api/items/${item.id}`);
      this.store.items = this.store.items.filter(otherItem => otherItem.id !== item.id);
    },

    setNeeded(item, needed) {
      this.$set(this, 'itemChangeUnsaved', true);
      item.needed = needed;
      this.debouncedPatchItem(item.id, item.needed);
    },

    debouncedPatchItem: debounce(function (itemId, newNeeded) {
      const payload = {
        item: { needed: newNeeded},
      };
      this.$http.patch('api/items/' + itemId, payload).then(() => {
        this.$set(this, 'itemChangeUnsaved', false);
      });
    }, 500),

    postNewItem(event) {
      event.preventDefault();
      this.$set(this, 'postingItem', true);
      const payload = {
        item: {
          name: this.newItemName,
        },
      };
      this.$http.post(`api/stores/${this.store.id}/items`, payload).then(response => {
        this.newItemName = '';
        this.$set(this, 'postingItem', false);
        this.store.items.unshift(response.data);
      });
    },
  },

  props: [
    'store'
  ],
}
</script>

<style scoped>
#needed {
  margin-top: 20px;
  margin-bottom: 20px;
}
.spinner--circle {
  margin-left: 8px;
  display: inline-block;
  height: 14px;
  width: 14px;
}
.add-item-button { text-align: text-bottom; }
.decrement, .delete { color: crimson; }
.increment, .purchase { color: green; }
.store-name { margin-bottom: 0; }
.decrement, .increment, .purchase, .delete {
  padding-left: 10px;
  font-weight: bold;
  font-size: 15px;
  -webkit-user-select: none;
  -moz-user-select: none;
  -khtml-user-select: none;
  -ms-user-select: none;
}
</style>
