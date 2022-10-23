<template lang='pug'>
.grocery-item.flex.items-center(
  :class='{unneeded: item.needed <= 0, "appear-vertically": item.newlyAdded}'
)
  .left.nowrap
    button.increment.h2.js-link.olive(@click='setNeeded(item, item.needed + 1)' title='Increment')
      span +
    button.decrement.h2.mx1.js-link.red(
      @click='decrement(item)'
      title='Decrement'
    )
      span &ndash;
  .left
    input(
      v-if='editingName'
      type='text'
      :value='item.name'
      @blur='stopEditingAndUpdateItemName()'
      @keydown.enter='stopEditingAndUpdateItemName()'
      ref='item-name-input'
    )
    span.item-name(v-else)
      | {{item.name}}
      |
      a.js-link.gray(@click='editItemName')
        edit-icon(size='17')
    | &nbsp;
    span ({{item.needed}})
  .delete.h2.pl1.pr1.js-link.right.red(
    v-if='ownStore'
    @click="groceriesStore.deleteItem({ item })"
    title='Delete item'
  ) ×
</template>

<script>
import { useGroceriesStore } from '@/groceries/store';
import { debounce } from 'lodash-es';
import { EditIcon } from 'vue-tabler-icons';

export default {
  components: {
    EditIcon,
  },

  data() {
    return {
      editingName: false,
      groceriesStore: useGroceriesStore(),
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

    setNeeded(item, needed) {
      item.needed = needed;
      this.groceriesStore.setCollectingDebounces({ value: true });
      this.debouncedPatchItem(item);
    },

    stopEditingAndUpdateItemName() {
      this.editingName = false;
      this.groceriesStore.updateItem({
        item: this.item,
        attributes: {
          name: this.$refs['item-name-input'].value,
        },
      });
    },

    // we need `function` for correct `this`
    // eslint-disable-next-line func-names
    debouncedPatchItem: debounce(function (item) {
      this.groceriesStore.updateItem({ item, attributes: item });
      this.groceriesStore.setCollectingDebounces({ value: false });
    }, 333),
  },

  props: {
    item: {
      type: Object,
      required: true,
    },

    ownStore: {
      required: true,
      type: Boolean,
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

.delete {
  margin-left: auto;
}

button.decrement,
button.increment {
  border: none;
  border: 1px solid silver;
  font-size: 20px;
  font-weight: bold;
  vertical-align: middle;
  padding: 0;
  cursor: pointer;
  outline: inherit;
  height: 25px;
  width: 35px;
  border-radius: 3px;
  background: none;

  span {
    position: relative;
    top: -1px;
  }

  @media (hover: hover) {
    &:hover {
      background: white;
    }
  }
}

.item-name {
  word-break: break-word;
}

.grocery-item {
  background: rgba(255, 255, 255, 60%);
  margin: 5px 0;
  padding: 6px;
  min-height: 30px;

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
