<template lang="pug">
form.flex(v-if='store.own_store' @submit.prevent='postNewItem')
  .float-left
    el-input.item-name-input.max-w-60(
      placeholder='Add an item'
      type='text'
      v-model='formData.newItemName'
      name='newItemName'
    )
  .ml-2
    el-button.button.button-outline(
      native-type='submit'
      :disabled='v$.$invalid'
    ) Add
</template>

<script setup lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { ElButton, ElInput } from 'element-plus';
import { reactive, type PropType } from 'vue';

import { useGroceriesStore } from '@/groceries/store';
import type { Store } from '@/types';

const props = defineProps({
  store: {
    type: Object as PropType<Store>,
    required: true,
  },
});

const groceriesStore = useGroceriesStore();

const vuelidateRules = {
  newItemName: { required },
};
const formData = reactive({
  newItemName: '',
});
const v$ = useVuelidate(vuelidateRules, formData);

async function postNewItem() {
  const success = await groceriesStore.createItem({
    store: props.store,
    itemAttributes: {
      name: formData.newItemName,
    },
  });

  if (success) {
    formData.newItemName = '';
  }
}
</script>
