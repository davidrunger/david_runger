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
      :disabled="v$.$invalid"
    ) Add
</template>

<script setup lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { ElButton, ElInput } from 'element-plus';
import { reactive } from 'vue';
import { object } from 'vue-types';

import { useGroceriesStore } from '@/groceries/store';
import type { Store } from '@/types';

const props = defineProps({
  store: object<Store>().isRequired,
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
