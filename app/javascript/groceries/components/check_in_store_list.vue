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

<script>
import { useGroceriesStore } from '@/groceries/store';

export default {
  data() {
    return {
      groceriesStore: useGroceriesStore(),
    };
  },

  props: {
    stores: {
      required: true,
      type: Array,
    },
  },
};
</script>
