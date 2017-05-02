  <template lang="pug">
  div.mt1.mb2
    span.store-name.h2.blue-medium {{ store.name }}
    ul.list-reset.mt0.mb0.pl1
      li(v-for='item in store.items')
        | {{item.name}}
        | ({{item.needed}})
        span.decrement.h2.pl1.pr1.js-link(v-on:click='changeNeeded(item, -1)') ⋁
        span.increment.h2.js-link(v-on:click='changeNeeded(item, 1)') ⋀
    div.h2.blue-dark(v-if='addingItem')
</template>

<script>
const debounce = require('lodash').debounce;

module.exports = {
  data: () => {
    return {
      addingItem: false,
    };
  },

  methods: {
    changeNeeded(item, changeAmount) {
      console.log('changing needed', item.id, item.name, changeAmount);
      console.log(this.debouncedPatchItem);
      item.needed += changeAmount;
      this.debouncedPatchItem(item.id, item.needed);
    },

    debouncedPatchItem: debounce(function (itemId, newNeeded) {
      const payload = {
        item: { needed: newNeeded},
      };
      this.$http.patch('api/items/' + itemId, payload);
    }, 1000),

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
