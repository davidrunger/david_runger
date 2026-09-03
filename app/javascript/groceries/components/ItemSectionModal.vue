<template lang="pug">
Modal(
  :name="modalName"
  width="85%"
  maxWidth="400px"
)
  form(@submit.prevent="save")
    h3.mb-2.font-bold {{ assignment ? 'Change section' : 'Choose section' }}
    p.mb-4.text-sm.text-neutral-600 {{ item.name }} at {{ store.name }}

    template(v-if="storeSectionScheme?.store_sections.length")
      ElSelect.w-full(
        v-model="selectedStoreSectionId"
        clearable
        placeholder="Choose a section"
      )
        ElOption(
          v-for="storeSection in storeSectionScheme.store_sections"
          :key="storeSection.id"
          :label="storeSection.name"
          :value="storeSection.id"
        )

      .mt-5.flex.justify-around
        ElButton(
          type="primary"
          link
          @click="close"
        ) Cancel
        ElButton(
          type="primary"
          native-type="submit"
          :loading="saving"
        ) Save
    template(v-else)
      p.text-sm.text-neutral-600 Add a section before choosing one for this item.
      .mt-5.flex.justify-around
        ElButton(
          type="primary"
          link
          @click="close"
        ) Cancel
        ElButton(
          type="primary"
          @click="manageStoreSections"
        ) Manage sections
</template>

<script setup lang="ts">
import { ElButton, ElOption, ElSelect } from 'element-plus';
import { computed, ref, watch } from 'vue';
import { object } from 'vue-types';

import Modal from '@/components/Modal.vue';
import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import { useModalStore } from '@/lib/modal/store';
import type { Store } from '@/types';

const props = defineProps({
  item: object<Item>().isRequired,
  store: object<Store>().isRequired,
});

const modalName = 'choose-item-section';
const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
const saving = ref(false);
const selectedStoreSectionId = ref<number>();

const showingModal = computed(() => modalStore.showingModal({ modalName }));
const assignment = computed(() => {
  return props.store.item_section_assignments.find(
    (candidateAssignment) => candidateAssignment.item_id === props.item.id,
  );
});
const storeSectionScheme = computed(
  () => props.store.section_configuration?.store_section_scheme || null,
);

watch(
  showingModal,
  (showing) => {
    if (showing)
      selectedStoreSectionId.value = assignment.value?.store_section_id;
  },
  { immediate: true },
);

function close() {
  modalStore.hideModal({ modalName });
}

function manageStoreSections() {
  close();
  modalStore.showModal({ modalName: 'manage-store-sections' });
}

async function save() {
  const storeSectionId = selectedStoreSectionId.value;
  const storeSection = storeSectionScheme.value?.store_sections.find(
    (candidateStoreSection) => candidateStoreSection.id === storeSectionId,
  );

  saving.value = true;
  try {
    if (storeSection) {
      if (
        !(await groceriesStore.updateItemSectionAssignment({
          item: props.item,
          store: props.store,
          storeSection,
        }))
      )
        return;
    } else if (assignment.value) {
      await groceriesStore.deleteItemSectionAssignment({
        item: props.item,
        store: props.store,
      });
    }

    close();
  } finally {
    saving.value = false;
  }
}
</script>
