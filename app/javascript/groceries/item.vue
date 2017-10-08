<template lang='pug'>
  li(:class='{unneeded: item.needed <= 0}' @dblclick='editingName = true')
    input(v-if='editingName' type='text' autofocus :value='item.name' @blur='editingName = false;')
    span(v-else) {{item.name}}
    | &nbsp;
    span ({{item.needed}})
    span.increment.h2.js-link(@click='setNeeded(item, item.needed + 1)') +
    span.decrement.h2.pl1.pr1.js-link(@click='setNeeded(item, item.needed - 1)') &ndash;
    span.purchase.h2.pl1.pr1.js-link(@click='setNeeded(item, 0)') ✓
    span.delete.h2.pl1.pr1.js-link(@click='deleteItem(item)') ×
</template>

<script>
import { debounce } from 'lodash';

export default {
  data() {
    return {
      editingName: false,
    };
  },

  methods: {
    deleteItem(item) {
      this.$store.dispatch('deleteItem', item.id);
    },

    setNeeded(item, needed) {
      item.needed = needed;
      this.debouncedPatchItem(item.id, item.needed);
    },

    // we need `function` for correct `this`
    // eslint-disable-next-line func-names
    debouncedPatchItem: debounce(function (itemId, newNeeded) {
      const payload = {
        item: { needed: newNeeded },
      };
      this.$http.patch(`api/items/${itemId}`, payload);
    }, 500),
  },

  props: [
    'item',
  ],
};
</script>

<style scoped>
.decrement, .delete { color: crimson; }
.increment, .purchase { color: green; }

.decrement, .increment, .purchase, .delete {
  padding-left: 10px;
  font-weight: bold;
  font-size: 15px;
  -webkit-user-select: none;
  -moz-user-select: none;
  -khtml-user-select: none;
  -ms-user-select: none;
}

li {
  display: flex;
  background: rgba(255, 255, 255, 0.5);
  font-size: 16px;
  margin: 5px 10px;
  padding: 5px 10px;
  min-height: 27px;
  line-height: 18px;

  &.unneeded {
    background: rgba(255, 255, 255, 0.3);
    color: rgba(0, 0, 0, 0.5);
  }

  .item-name {
    flex: 1;
  }

  .delete {
    color: crimson;
    height: 20px;
    width: 20px;
    margin-left: 10px;
    font-weight: bold;
    font-size: 15px;
    text-align: center;
    padding: 0;
  }
}
</style>
