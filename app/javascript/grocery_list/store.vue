  <template lang="pug">
  div.mt1.mb2
    h1.store-name.h2.blue-medium {{ store.name }}

    a.h3.js-link(v-if='!addingItem' v-on:click='toggleAddingItem') Add an item #[span.bold +]
    form(v-if='addingItem' v-on:submit='postNewItem')
      input#item-name-input.float-left(type='text' ref='itemName' v-model='newItemName'
        placeholder='Enter the item'
      )
      input#add-item-button.button.button-outline.float-left.ml2(type='submit' value='Add')
      a.h3.js-link(v-on:click='toggleAddingItem') Cancel

    ul.list-reset.mt0.mb0.pl1
      li(v-for='item in store.items')
        | {{item.name}}
        | ({{item.needed}})
        span.increment.h2.js-link(v-on:click='changeNeeded(item, 1)') ⋀
        span.decrement.h2.pl1.pr1.js-link(v-on:click='changeNeeded(item, -1)') ⋁
    div.h2.blue-dark(v-if='addingItem')
</template>

<script>
const debounce = require('lodash').debounce;

module.exports = {
  data: () => {
    return {
      addingItem: false,
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
      const payload = {
        item: {
          name: this.newItemName,
        },
      };
      this.$http.post(`api/stores/${this.store.id}/items`, payload).then(response => {
        this.newItemName = '';
        this.$set(this, 'addingItem', false);
        this.store.items.unshift(response.data);
      });
    },

    toggleAddingItem() {
      this.$set(this, 'addingItem', !this.addingItem);
      if (this.addingItem) this.$nextTick(() => this.$refs.itemName.focus());
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
.increment { color: limegreen; }
.store-name { margin-bottom: 0; }
.decrement, .increment {
  -webkit-user-select: none;
  -moz-user-select: none;
  -khtml-user-select: none;
  -ms-user-select: none;
}
</style>
