<template lang='pug'>
  drag(:transferData='item')
    li(:class='{unneeded: item.needed <= 0, "just-added": isJustAdded(item)}')
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
      span.increment.h2.js-link(@click='setNeeded(item, item.needed + 1)' title='Increment') +
      span.decrement.h2.pl1.pr1.js-link(@click='setNeeded(item, item.needed - 1)' title='Decrement') &ndash;
      span.purchase.h2.pl1.pr1.js-link(@click='setNeeded(item, 0)' title='Mark as purchased') ✓
      span.delete.h2.pl1.pr1.js-link(@click='deleteItem(item)' title='Delete item') ×
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

    isJustAdded(item) {
      return !!item.createdAt && item.createdAt > ((new Date()).valueOf() - 1000);
    },

    setNeeded(item, needed) {
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
      this.$http.patch(this.$routes.api_item_path(itemId), payload);
    }, 500),
  },

  props: [
    'item',
  ],
};
</script>

<style scoped>
.decrement,
.delete {
  color: crimson;
}

.increment,
.purchase {
  color: green;
}

.decrement,
.increment,
.purchase,
.delete {
  padding-left: 10px;
  font-weight: bold;
  font-size: 15px;
  -webkit-user-select: none;
  -moz-user-select: none;
  -khtml-user-select: none;
  -ms-user-select: none;
}

@keyframes appear {
  from {
    opacity: 0;
    transform: scale(0);
  }

  to {
    opacity: 1;
    transform: scale(1);
  }
}

.just-added {
  animation-name: appear;
  animation-duration: 0.7s;
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
