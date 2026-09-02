<template lang="pug">
Modal(
  :name="modalName"
  width="85%"
  maxWidth="450px"
)
  form(@submit.prevent="savePrivacy")
    h3.mb-4.font-bold Privacy for {{ store.name }}

    fieldset.privacy-options
      legend.sr-only Store privacy

      label.privacy-option
        input(
          v-model="privateStore"
          type="radio"
          :value="false"
        )
        span.privacy-option__content
          span.privacy-option__label Public
          span.privacy-option__description Your spouse can view this store.

      label.privacy-option
        input(
          v-model="privateStore"
          type="radio"
          :value="true"
        )
        span.privacy-option__content
          span.privacy-option__label
            LockIcon(
              size="19"
              aria-hidden="true"
            )
            | Private
          span.privacy-option__description Only you can view this store.

    .mt-5.flex.justify-around
      ElButton(
        type="primary"
        link
        @click="cancel"
      ) Cancel
      ElButton(
        type="primary"
        native-type="submit"
        :disabled="privateStore === store.private"
        :loading="saving"
      ) Save
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { computed, ref, watch } from 'vue';
import { LockIcon } from 'vue-tabler-icons';
import { object } from 'vue-types';

import Modal from '@/components/Modal.vue';
import { useGroceriesStore } from '@/groceries/store';
import { useModalStore } from '@/lib/modal/store';
import type { Store } from '@/types';

const props = defineProps({
  store: object<Store>().isRequired,
});

const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
const modalName = 'store-privacy';
const privateStore = ref(false);
const saving = ref(false);

const showingModal = computed(() => modalStore.showingModal({ modalName }));

watch(
  showingModal,
  (showing) => {
    if (showing) privateStore.value = props.store.private;
  },
  { immediate: true },
);

function cancel(): void {
  modalStore.hideModal({ modalName });
}

async function savePrivacy(): Promise<void> {
  if (privateStore.value === props.store.private) return;

  saving.value = true;

  try {
    await groceriesStore.updateStore({
      store: props.store,
      attributes: { private: privateStore.value },
    });
    modalStore.hideModal({ modalName });
  } finally {
    saving.value = false;
  }
}
</script>

<style lang="scss" scoped>
.privacy-options {
  display: grid;
  gap: 10px;
}

.privacy-option {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 11px 13px;
  cursor: pointer;
  background: rgb(223, 231, 215, 42%);
  border: 1px solid rgb(198, 203, 185, 55%);
  border-radius: 10px;

  input {
    margin-top: 3px;
  }
}

.privacy-option__content {
  display: grid;
  gap: 3px;
}

.privacy-option__label {
  display: flex;
  align-items: center;
  gap: 5px;
  font-weight: 600;
}

.privacy-option__description {
  color: #586359;
  font-size: 0.9rem;
  line-height: 1.4;
}
</style>
