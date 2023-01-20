<template lang='pug'>
ul
  li.block.mb1(
    v-for='(store, index) in stores'
    :key='store.id'
  )
    input(
      type='checkbox'
      v-model='groceriesStore.checkInStores'
      :value='store'
      :id='`checkin-stores-${store.id}`'
    )
    label.ml1(:for='`checkin-stores-${store.id}`') {{store.name}}
</template>

<script lang='ts'>
import { defineComponent, PropType } from 'vue';
import { useGroceriesStore } from '@/groceries/store';
import { Store } from '@/groceries/types';

export default defineComponent({
  data() {
    return {
      groceriesStore: useGroceriesStore(),
    };
  },

  props: {
    stores: {
      required: true,
      type: Array as PropType<Array<Store>>,
    },
  },
});
</script>
