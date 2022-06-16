<template lang='pug'>
.grocery-item.flex.items-center(
  :class='{unneeded: item.needed <= 0, "appear-vertically": isJustAdded(item)}'
)
  div
    span.increment.h2.js-link.olive(@click='setNeeded(item, item.needed + 1)' title='Increment') +
    span.decrement.h2.pl1.pr1.js-link.red(
      @click='decrement(item)'
      title='Decrement'
    ) &ndash;
    input(
      v-if='editingName'
      type='text'
      :value='item.name'
      @blur='stopEditingAndUpdateItemName()'
      @keydown.enter='stopEditingAndUpdateItemName()'
      ref='item-name-input'
    )
    span(v-else)
      | {{item.name}}
      |
      a.js-link.gray(@click='editItemName')
        font-awesome-icon(icon='fa-regular fa-edit')
    | &nbsp;
    span ({{item.needed}})
    .delete.h2.pl1.pr1.js-link.right.red(
      @click="$store.dispatch('deleteItem', { item })"
      title='Delete item'
    ) ×
</template>

<script>
import { debounce } from 'lodash-es';

export default {
  data() {
    return {
      editingName: false,
    };
  },

  methods: {
    decrement(item) {
      const newNeededCount = item.needed - 1;
      if (newNeededCount >= 0) {
        this.setNeeded(item, newNeededCount);
      }
    },

    editItemName() {
      this.editingName = true;
      // wait a tick for input to render, then focus it
      setTimeout(() => { this.$refs['item-name-input'].focus(); });
    },

    isJustAdded(item) {
      return !!item.createdAt && item.createdAt > ((new Date()).valueOf() - 1000);
    },

    setNeeded(item, needed) {
      this.$store.commit('setCollectingDebounces', { value: true });
      item.needed = needed;
      this.debouncedPatchItem(item.id, item.needed);
    },

    stopEditingAndUpdateItemName() {
      this.editingName = false;
      this.$store.dispatch('updateItem', {
        item: this.item,
        attributes: {
          name: this.$refs['item-name-input'].value,
        },
      });
    },

    // we need `function` for correct `this`
    // eslint-disable-next-line func-names
    debouncedPatchItem: debounce(function (itemId, newNeeded) {
      const payload = {
        item: { needed: newNeeded },
      };
      this.$http.patch(this.$routes.api_item_path(itemId), { json: payload }).json().
        then(() => { this.$store.commit('decrementPendingRequests'); });
      this.$store.commit('incrementPendingRequests');
      // set collectingDebounces to false _after_ incrementing pendingRequests so that
      // debouncingOrWaitingOnNetwork stays consistently true
      this.$store.commit('setCollectingDebounces', { value: false });
    }, 333),
  },

  props: {
    item: {
      type: Object,
      required: true,
    },
  },
};
</script>

<style lang='scss' scoped>
.decrement,
.increment,
.delete {
  font-size: 15px;
  user-select: none;
}

.grocery-item {
  background: rgba(255, 255, 255, 60%);
  margin: 5px 0;
  padding: 0 6px;
  height: 30px;

  &:not(.unneeded):hover {
    background: rgba(255, 255, 255, 80%);

    @media (hover: none), (hover: on-demand) {
      background: rgba(255, 255, 255, 60%);
    }
  }

  &.unneeded {
    background: rgba(255, 255, 255, 30%);
    color: rgba(0, 0, 0, 55%);

    &:hover {
      background: rgba(255, 255, 255, 50%);

      @media (hover: none), (hover: on-demand) {
        background: rgba(255, 255, 255, 30%);
      }
    }
  }
}
</style>
