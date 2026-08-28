<template lang="pug">
Modal(
  name="manage-check-in-stores"
  width="80%"
  maxWidth="370px"
)
  slot
    h4.mt-2.mb-4.font-bold.
      Which stores would you like to check in?
    CheckInStoreList(:stores="groceriesStore.sortedStores")
    h4.mb-4.font-bold.
      Spouse's stores
    CheckInStoreList(:stores="groceriesStore.sortedSpouseStores")
    .mt-4.flex.justify-around
      ElButton(
        @click="modalStore.hideModal({ modalName: 'manage-check-in-stores' })"
        type="primary"
      ) Done
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';

import Modal from '@/components/Modal.vue';
import { useGroceriesStore } from '@/groceries/store';
import { useModalStore } from '@/lib/modal/store';

import CheckInStoreList from './CheckInStoreList.vue';

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
</script>
