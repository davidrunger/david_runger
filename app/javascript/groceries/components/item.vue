<template lang='pug'>
  drag(:transferData='item')
    li.my1.p1(:class='{unneeded: item.needed <= 0, "appear-vertically": isJustAdded(item)}')
      span.increment.h2.js-link.olive(@click='setNeeded(item, item.needed + 1)' title='Increment') +
      span.decrement.h2.pl1.pr1.js-link.red(@click='setNeeded(item, item.needed - 1)' title='Decrement') &ndash;
      input(
        v-if='editingName'
        type='text'
        autofocus
        v-model='item.name'
        @blur='stopEditingAndUpdateItemName()'
        @keydown.enter='stopEditingAndUpdateItemName()'
      )
      span(v-else @dblclick='editingName = true') {{item.name}}
      | &nbsp;
      span ({{item.needed}})
      .delete.h2.pl1.pr1.js-link.right.red(
        @click="$store.dispatch('deleteItem', item)"
        title='Delete item'
      ) ×
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
    isJustAdded(item) {
      return !!item.createdAt && item.createdAt > ((new Date()).valueOf() - 1000);
    },

    setNeeded(item, needed) {
      this.$store.commit('setCollectingDebounces', true);
      item.needed = needed;
      this.debouncedPatchItem(item.id, item.needed);
    },

    stopEditingAndUpdateItemName() {
      this.editingName = false;
      this.$store.dispatch('updateItem', {
        id: this.item.id,
        attributes: {
          name: this.item.name,
        },
      });
    },

    // we need `function` for correct `this`
    // eslint-disable-next-line func-names
    debouncedPatchItem: debounce(function (itemId, newNeeded) {
      const payload = {
        item: { needed: newNeeded },
      };
      this.$http.patch(this.$routes.api_item_path(itemId), payload).
        then(() => { this.$store.commit('decrementPendingRequests'); });
      this.$store.commit('incrementPendingRequests');
      // set collectingDebounces to false _after_ incrementing pendingRequests so that
      // debouncingOrWaitingOnNetwork stays consistently true
      this.$store.commit('setCollectingDebounces', false);
    }, 500),
  },

  props: [
    'item',
  ],
};
</script>

<style scoped>
.decrement,
.increment,
.delete {
  font-size: 15px;
  -webkit-user-select: none;
  -moz-user-select: none;
  -khtml-user-select: none;
  -ms-user-select: none;
}

li {
  background: rgba(255, 255, 255, 0.5);

  &.unneeded {
    background: rgba(255, 255, 255, 0.3);
    color: rgba(0, 0, 0, 0.55);
  }
}
</style>
