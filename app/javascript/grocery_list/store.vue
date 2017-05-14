  <template lang="pug">
  div.mt1.mb2
    h1.store-name.h2.blue-medium {{ store.name }}

    form(v-on:submit='postNewItem')
      input#item-name-input.float-left(type='text' ref='itemName' v-model='newItemName'
        placeholder='Add an item'
      )
      input#add-item-button.button.button-outline.float-left.ml2(type='submit' value='Add')

    ul.list-reset.mt0.mb0.pl1
      li.blue-dark(v-if='postingItem') Saving ...
      li(v-for='item in store.items')
        | {{item.name}}
        | ({{item.needed}})
        span.increment.h2.js-link(v-on:click='changeNeeded(item, 1)') +
        span.decrement.h2.pl1.pr1.js-link(v-on:click='changeNeeded(item, -1)') &ndash;
</template>

<script>
const debounce = require('lodash').debounce;

module.exports = {
  data: () => {
    return {
      postingItem: false,
      newItemName: '',
    };
  },

  methods: {
    changeNeeded(item, changeAmount) {
      item.needed += changeAmount;
      this.debouncedPatchItem(item.id, item.needed);
    },

    debouncedPatchItem: debounce(function (itemId, newNeeded) {
      const payload = {
        item: { needed: newNeeded},
      };
      this.$http.patch('api/items/' + itemId, payload);
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
.add-item-button { text-align: text-bottom; }
.decrement { color: crimson; }
.increment { color: green; }
.store-name { margin-bottom: 0; }
.decrement, .increment {
  padding-left: 10px;
  font-weight: bold;
  font-size: 15px;
  -webkit-user-select: none;
  -moz-user-select: none;
  -khtml-user-select: none;
  -ms-user-select: none;
}
</style>
