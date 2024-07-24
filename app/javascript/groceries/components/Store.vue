<template lang="pug">
.store-container.overflow-auto.hidden-scrollbars.pt-2.pl-8.pr-4
  h2.store-name.my-4
    input(
      v-if='editingName'
      type='text'
      v-model='store.name'
      @blur='stopEditingAndUpdateStoreName()'
      @keydown.enter='stopEditingAndUpdateStoreName()'
      ref='storeNameInput'
    )
    span(v-if='!editingName') {{ store.name }}
    a.edit-store.js-link.text-neutral-400.ml-2(@click='editStoreName')
      edit-icon(size='27')
    span(v-if='store.own_store')
      el-button.ml-2(v-if='store.private' size='small' @click='togglePrivacy') Make public
      el-button.ml-2(v-else size='small' @click='togglePrivacy') Make private
    span.spinner--circle.ml-2(v-if='debouncingOrWaitingOnNetwork')
  div.buttons-container.mb-4
    el-button.mr-2.mt-2(
      id="show-modal"
      @click='initializeTripCheckIn'
      :size='$is_mobile_device ? "small" : null'
    ) Check in items

  div.mb-2
    el-input(
      v-if='editingNotes'
      type='textarea'
      placeholder='Member phone number: 619-867-5309'
      v-model='store.notes'
      @blur='stopEditingAndUpdateStoreNotes()'
      ref='storeNotesInput'
    )
    p.whitespace-pre-wrap(v-else)
      | {{store.notes || 'No notes yet'}}
      a.edit-store.js-link.text-neutral-400.ml-2(v-if='store.own_store' @click='editStoreNotes')
        edit-icon(size='18')

  form.flex(v-if='store.own_store' @submit.prevent='postNewItem')
    .float-left
      el-input.item-name-input(
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

  TransitionGroup(
    name='appear-and-disappear-vertically-list'
    tag='div'
    class='items-list relative mt-0 mb-0'
  )
    Item(
      v-for='item in sortedItems'
      :item="item"
      :key="item.id"
      :ownStore='store.own_store'
    )

  CheckInModal

  ManageCheckInStoresModal
</template>

<script setup lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { storeToRefs } from 'pinia';
import Toastify from 'toastify-js';
import { computed, reactive, ref, type PropType } from 'vue';
import { EditIcon } from 'vue-tabler-icons';

import { helpers, useGroceriesStore } from '@/groceries/store';
import type { Item as ItemType, Store } from '@/groceries/types';
import { useModalStore } from '@/shared/modal/store';

import CheckInModal from './CheckInModal.vue';
import Item from './Item.vue';
import ManageCheckInStoresModal from './ManageCheckInStoresModal.vue';

const props = defineProps({
  store: {
    type: Object as PropType<Store>,
    required: true,
  },
});

const vuelidateRules = {
  newItemName: { required },
};
const formData = reactive({
  newItemName: '',
});
const v$ = useVuelidate(vuelidateRules, formData);

const editingName = ref(false);
const editingNotes = ref(false);
const storeNameInput = ref(null);
const storeNotesInput = ref(null);
const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();

const { debouncingOrWaitingOnNetwork } = storeToRefs(groceriesStore);

const sortedItems = computed((): ItemType[] => {
  return helpers.sortByName(props.store.items);
});

function editStoreName() {
  editingName.value = true;
  // wait a tick for input to render, then focus it
  setTimeout(focusStoreNameInput);
}

function editStoreNotes() {
  editingNotes.value = true;
  // wait a tick for input to render, then focus it
  setTimeout(focusStoreNotesInput);
}

function focusStoreNameInput(callsAlready = 0) {
  if (!editingName.value) return;

  if (storeNameInput.value) {
    (storeNameInput.value as HTMLInputElement).focus();
  } else if (callsAlready < 20) {
    // the storeNameInput hasn't had time to render yet; retry later
    setTimeout(() => {
      focusStoreNameInput(callsAlready + 1);
    }, 50);
  }
}

function focusStoreNotesInput(callsAlready = 0) {
  if (!editingNotes.value) return;

  if (storeNotesInput.value) {
    (storeNotesInput.value as HTMLInputElement).focus();
  } else if (callsAlready < 20) {
    // the storeNotesInput hasn't had time to render yet; retry later
    setTimeout(() => {
      focusStoreNotesInput(callsAlready + 1);
    }, 50);
  }
}

function initializeTripCheckIn() {
  groceriesStore.addCheckInStore({
    store: groceriesStore.currentStore as Store,
  });
  modalStore.showModal({ modalName: 'check-in-shopping-trip' });
}

function postNewItem() {
  groceriesStore
    .createItem({
      store: props.store,
      itemAttributes: {
        name: formData.newItemName,
      },
    })
    .catch(async ({ response }: { response: Response }) => {
      groceriesStore.decrementPendingRequests();
      const { errors } = await response.json();
      for (const errorMessage of errors) {
        Toastify({
          text: errorMessage,
          className: 'error',
          position: 'center',
          duration: 2500,
        }).showToast();
      }
    });
  formData.newItemName = '';
}

function stopEditingAndUpdateStoreName() {
  editingName.value = false;
  groceriesStore.updateStore({
    store: props.store,
    attributes: {
      name: props.store.name,
    },
  });
}

function stopEditingAndUpdateStoreNotes() {
  editingNotes.value = false;
  groceriesStore.updateStore({
    store: props.store,
    attributes: {
      notes: props.store.notes,
    },
  });
}

function togglePrivacy() {
  groceriesStore.updateStore({
    store: props.store,
    attributes: {
      private: !props.store.private,
    },
  });
}
</script>

<style lang="scss" scoped>
button.choose-stores {
  font-size: inherit;
  padding: 0;
  position: relative;
  top: -0.5px;
}

// https://stackoverflow.com/a/30891910/4009384
.buttons-container {
  margin-top: calc(-1 * var(--space-1));
}

.store-container {
  max-height: 97vh; // fallback for browsers that don't yet support `dvh` units
  max-height: 97dvh;
}

.item-name-input {
  max-width: 230px;
}

.spinner--circle {
  height: 14px;
  width: 14px;
}

.edit-store {
  &:hover {
    color: black;
  }
}
</style>
