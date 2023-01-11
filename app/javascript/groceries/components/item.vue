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
      @blur='stopEditingAndUpdateItemName'
      @keydown.enter='stopEditingAndUpdateItemName'
      @keydown.escape='editingName = false;'
      ref='item-name-input'
    )
    span.item-name(v-else)
      | {{item.name}}
      |
      a.js-link.gray(@click='editItemName')
        edit-icon(size='17')
    | &nbsp;
    span ({{item.needed}})
    el-button(
      link
      type='primary'
      @click='unskip(item)'
      v-if='groceriesStore.skippedItems.includes(item)'
    ) Unskip
  .delete.h2.pl1.pr1.js-link.right.red(
    v-if='ownStore'
    @click="groceriesStore.destroyItem({ item })"
    title='Delete item'
  ) ×
</template>

<script lang='ts'>
import { defineComponent, PropType } from 'vue';
import { debounce, noop } from 'lodash-es';
import { EditIcon } from 'vue-tabler-icons';
import { useGroceriesStore } from '@/groceries/store';
import { Item } from '@/groceries/types';

export default defineComponent({
  components: {
    EditIcon,
  },

  created() {
    this.debouncedPatchItem = debounce(this.patchItem, 333);
  },

  data() {
    return {
      debouncedPatchItem: noop,
      editingName: false,
      groceriesStore: useGroceriesStore(),
    };
  },

  methods: {
    decrement(item: Item) {
      const newNeededCount = item.needed - 1;
      if (newNeededCount >= 0) {
        this.setNeeded(item, newNeededCount);
      }
    },

    editItemName() {
      this.editingName = true;
      // wait a tick for input to render, then focus it
      setTimeout(() => { (this.$refs['item-name-input'] as HTMLInputElement).focus(); });
    },

    setNeeded(item: Item, needed: number) {
      item.needed = needed;
      this.groceriesStore.setCollectingDebounces({ value: true });
      this.debouncedPatchItem(item);
    },

    stopEditingAndUpdateItemName() {
      if (!this.$refs['item-name-input']) return; // was happening for me in Chrome in development

      this.editingName = false;
      this.groceriesStore.updateItem({
        item: this.item,
        attributes: {
          name: (this.$refs['item-name-input'] as HTMLInputElement).value,
        },
      });
    },

    patchItem(item: Item) {
      this.groceriesStore.updateItem({ item, attributes: item });
      this.groceriesStore.setCollectingDebounces({ value: false });
    },

    unskip(item: Item) {
      this.groceriesStore.unskipItem({ item });
    },
  },

  props: {
    item: {
      type: Object as PropType<Item>,
      required: true,
    },

    ownStore: {
      required: true,
      type: Boolean,
    },
  },
});
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
