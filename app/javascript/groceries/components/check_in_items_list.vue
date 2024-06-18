<template lang="pug">
ul.check-in-items-list.mb-2
  li.flex.items-center.mb-2(
    v-for='(item, index) in items'
    :key='item.id'
  )
    input(
      type='checkbox'
      v-model='itemsToZero'
      :value='item'
      :id='`trip-checkin-item-${item.id}`'
    )
    label.ml-2(:for='`trip-checkin-item-${item.id}`')
      span {{item.name}}
      span(v-if='item.needed > 1') {{' '}} ({{item.needed}})
      span.pr-1
      el-button(
        link
        type='primary'
        @click='skip(item)'
      ) Skip
</template>

<script lang="ts">
import { defineComponent, PropType } from 'vue';
import { Item } from '@/groceries/types';

export default defineComponent({
  props: {
    items: {
      type: Array as PropType<Array<Item>>,
      required: true,
    },
  },
});
</script>
