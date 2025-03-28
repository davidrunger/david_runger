<template lang="pug">
form.flex(
  v-if="store.own_store"
  @submit.prevent="postNewItem"
)
  .float-left
    ElInput.item-name-input.max-w-60(
      placeholder="Add an item"
      type="text"
      v-model="formData.newItemName"
      name="newItemName"
    )
  .ml-2
    ElButton.button.button-outline(
      native-type="submit"
      aria-label="Add item"
      :disabled="r$.$invalid"
    ) Add
</template>

<script setup lang="ts">
import { useRegle } from '@regle/core';
import { required } from '@regle/rules';
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
const { r$ } = useRegle(formData, vuelidateRules);

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
