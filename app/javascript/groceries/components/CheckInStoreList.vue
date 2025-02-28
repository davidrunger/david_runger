<template lang="pug">
ul
  li.block.mb-2(v-for='store in stores', :key='store.id')
    input(
      type='checkbox',
      v-model='groceriesStore.checkInStores',
      :value='store',
      :id='`checkin-stores-${store.id}`'
    )
    label.ml-2(:for='`checkin-stores-${store.id}`') {{ store.name }}
</template>

<script setup lang="ts">
import type { PropType } from 'vue';

import { useGroceriesStore } from '@/groceries/store';
import type { Store } from '@/types';

defineProps({
  stores: {
    required: true,
    type: Array as PropType<Array<Store>>,
  },
});

const groceriesStore = useGroceriesStore();
</script>
