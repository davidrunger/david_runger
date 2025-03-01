<template lang="pug">
Modal(name="manage-check-in-stores" width="80%" maxWidth="370px")
  slot
    h4.font-bold.mt-2.mb-4.
      Which stores would you like to check in?
    CheckInStoreList(:stores="groceriesStore.sortedStores")
    h4.font-bold.mb-4.
      Spouse's stores
    CheckInStoreList(:stores="groceriesStore.sortedSpouseStores")
    .flex.justify-around.mt-4
      el-button(
        @click="modalStore.hideModal({ modalName: 'manage-check-in-stores' })"
        type="primary"
      ) Done
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';

import { useGroceriesStore } from '@/groceries/store';
import { useModalStore } from '@/shared/modal/store';

import CheckInStoreList from './CheckInStoreList.vue';

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
</script>
