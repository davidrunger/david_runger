<template lang="pug">
Modal(
  :name="modalName"
  width="85%"
  maxWidth="460px"
)
  .store-sections-modal
    .flex.items-center.justify-center.gap-2.py-8(
      v-if="loadingStoreSectionSchemes"
    )
      span.spinner--circle.size-5
      span.text-sm.text-neutral-600 Loading store section layouts...

    template(v-else-if="showingConfiguration")
      h3.mb-2.font-bold Store sections
      p.mb-4.text-sm.text-neutral-600 Organize {{ store.name }} items by the part of the store where you buy them.

      ElRadioGroup.sectioning-options(
        v-model="configurationMode"
        :aria-label="`Section setup for ${store.name}`"
      )
        ElRadioButton(value="new") Create a new layout
        ElRadioButton(
          v-if="groceriesStore.storeSectionSchemes.length > 0"
          value="existing"
        ) Use an existing layout
        ElRadioButton(value="none") This store doesn't need sections

      label.mt-4.block(v-if="configurationMode === 'new'")
        span.mb-1.block.text-sm.font-semibold Layout name
        ElInput(
          v-model="newSchemeName"
          @keyup.enter="saveConfiguration"
        )

      label.mt-4.block(v-else-if="configurationMode === 'existing'")
        span.mb-1.block.text-sm.font-semibold Layout
        ElSelect.w-full(
          v-model="selectedSchemeId"
          placeholder="Choose a layout"
        )
          ElOption(
            v-for="scheme in groceriesStore.sortedStoreSectionSchemes"
            :key="scheme.id"
            :label="scheme.name"
            :value="scheme.id"
          )

      p.mt-4.text-sm.text-neutral-600(v-else) We won't ask you to organize items for this store. You can change this later.

      p.mt-3.text-sm.text-red-700(v-if="configurationError") {{ configurationError }}

      .mt-5.flex.justify-around
        ElButton(
          type="primary"
          link
          @click="close"
        ) Cancel
        ElButton(
          type="primary"
          :loading="savingConfiguration"
          @click="saveConfiguration"
        ) {{ configurationMode === 'none' ? 'Save choice' : 'Save layout' }}

    template(v-else-if="storeSectionScheme")
      .flex.items-start.justify-between.gap-3
        div
          h3.mb-1.font-bold Sections for {{ store.name }}
          p.text-sm.text-neutral-600 Using the {{ storeSectionScheme.name }} layout.
        ElButton(
          link
          type="primary"
          @click="showingConfiguration = true"
        ) Change layout

      ul.section-list.mt-4(v-if="storeSectionScheme.store_sections.length > 0")
        li.flex.items-center.gap-2(
          v-for="storeSection in sortedStoreSections"
          :key="storeSection.id"
        )
          label.flex-1
            span.sr-only Name for {{ storeSection.name }}
            ElInput.w-full(v-model="sectionNames[storeSection.id]")
          ElButton(
            link
            type="danger"
            @click="deleteStoreSection(storeSection)"
          ) Delete
      p.mt-4.text-sm.text-neutral-600(v-else) Add the first section for this layout below.

      form.mt-5.flex.gap-2(@submit.prevent="addStoreSection")
        label.flex-1
          span.sr-only Add a section
          ElInput(
            v-model="newSectionName"
            placeholder="Add a section"
          )
        ElButton(
          native-type="submit"
          type="primary"
          :loading="addingStoreSection"
        ) Add

      .mt-5.flex.justify-center
        ElButton(
          type="primary"
          link
          :loading="savingSectionNames"
          @click="saveSectionNamesAndClose"
        ) Done
</template>

<script setup lang="ts">
import {
  ElButton,
  ElInput,
  ElOption,
  ElRadioButton,
  ElRadioGroup,
  ElSelect,
} from 'element-plus';
import { computed, ref, watch } from 'vue';
import { bool, object } from 'vue-types';

import Modal from '@/components/Modal.vue';
import { helpers, useGroceriesStore } from '@/groceries/store';
import { useModalStore } from '@/lib/modal/store';
import type { Store, StoreSection } from '@/types';

const props = defineProps({
  showItemChooserAfterConfiguration: bool().def(false),
  store: object<Store>().isRequired,
});

const emit = defineEmits<{
  configured: [];
}>();

const modalName = 'manage-store-sections';
const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
const addingStoreSection = ref(false);
const configurationError = ref('');
const configurationMode = ref<'existing' | 'new' | 'none'>('new');
const loadingStoreSectionSchemes = ref(false);
const newSchemeName = ref('');
const newSectionName = ref('');
const savingConfiguration = ref(false);
const savingSectionNames = ref(false);
const sectionNames = ref<Record<number, string>>({});
const selectedSchemeId = ref<number>();
const showingConfiguration = ref(true);
let sectionSchemesRequestVersion = 0;

const showingModal = computed(() => modalStore.showingModal({ modalName }));
const storeSectionScheme = computed(
  () => props.store.section_configuration?.store_section_scheme || null,
);
const sortedStoreSections = computed(() => {
  if (!storeSectionScheme.value) return [];

  return helpers.sortByName(storeSectionScheme.value.store_sections);
});

watch(
  showingModal,
  async (showing) => {
    if (!showing) {
      sectionSchemesRequestVersion += 1;
      return;
    }

    const requestVersion = ++sectionSchemesRequestVersion;
    loadingStoreSectionSchemes.value = true;

    try {
      await groceriesStore.pullStoreSectionSchemes();
      if (requestVersion === sectionSchemesRequestVersion) {
        resetConfigurationForm();
      }
    } finally {
      if (requestVersion === sectionSchemesRequestVersion) {
        loadingStoreSectionSchemes.value = false;
      }
    }
  },
  { flush: 'sync', immediate: true },
);

function close() {
  modalStore.hideModal({ modalName });
}

function resetConfigurationForm() {
  const configuration = props.store.section_configuration;
  const scheme = configuration?.store_section_scheme;
  const matchingScheme = matchingSchemeFor(props.store);

  showingConfiguration.value = !configuration?.sectioning_enabled;
  configurationMode.value =
    configuration?.sectioning_enabled ? 'existing'
    : configuration ? 'none'
    : matchingScheme ? 'existing'
    : 'new';
  newSchemeName.value = scheme?.name || props.store.name;
  selectedSchemeId.value = scheme?.id || matchingScheme?.id;
  configurationError.value = '';
  resetSectionNames(scheme);
}

async function saveConfiguration() {
  configurationError.value = '';
  savingConfiguration.value = true;

  try {
    if (configurationMode.value === 'none') {
      const saved = await groceriesStore.updateStoreSectionConfiguration({
        store: props.store,
        sectioningEnabled: false,
        storeSectionSchemeId:
          props.store.section_configuration?.store_section_scheme?.id || null,
      });
      if (saved) close();
      return;
    }

    let schemeId = selectedSchemeId.value;
    if (configurationMode.value === 'new') {
      const name = normalizedName(newSchemeName.value);
      if (!name) {
        configurationError.value = 'Enter a layout name.';
        return;
      }

      const createdScheme = await groceriesStore.createStoreSectionScheme({
        name,
      });
      if (!createdScheme) return;

      schemeId = createdScheme.id;
    }

    if (!schemeId) {
      configurationError.value = 'Choose a layout.';
      return;
    }

    const saved = await groceriesStore.updateStoreSectionConfiguration({
      store: props.store,
      sectioningEnabled: true,
      storeSectionSchemeId: schemeId,
    });
    if (saved) {
      resetConfigurationForm();
      const scheme = groceriesStore.storeSectionSchemes.find(
        (candidateScheme) => candidateScheme.id === schemeId,
      );
      if (
        props.showItemChooserAfterConfiguration &&
        scheme?.store_sections.length
      ) {
        emit('configured');
      }
    }
  } finally {
    savingConfiguration.value = false;
  }
}

async function addStoreSection() {
  if (!storeSectionScheme.value) return;

  const name = normalizedName(newSectionName.value);
  if (!name) return;

  addingStoreSection.value = true;
  try {
    if (
      await groceriesStore.createStoreSection({
        storeSectionScheme: storeSectionScheme.value,
        name,
      })
    ) {
      newSectionName.value = '';
      resetSectionNames();
      if (props.showItemChooserAfterConfiguration) emit('configured');
    }
  } finally {
    addingStoreSection.value = false;
  }
}

async function deleteStoreSection(storeSection: StoreSection) {
  if (!storeSectionScheme.value) return;

  if (
    !window.confirm(
      `Delete the ${storeSection.name} section? Items in it will need a section again.`,
    )
  ) {
    return;
  }

  await groceriesStore.deleteStoreSection({
    storeSectionScheme: storeSectionScheme.value,
    storeSection,
  });
  resetSectionNames();
}

async function saveSectionNamesAndClose() {
  const scheme = storeSectionScheme.value;
  if (!scheme) return;

  savingSectionNames.value = true;
  try {
    const updates = scheme.store_sections.flatMap((storeSection) => {
      const name = normalizedName(
        sectionNames.value[storeSection.id] ?? storeSection.name,
      );
      if (!name || name === storeSection.name) {
        sectionNames.value[storeSection.id] = storeSection.name;
        return [];
      }

      return [{ name, storeSection, storeSectionScheme: scheme }];
    });
    const updated = await groceriesStore.updateStoreSections({ updates });
    resetSectionNames();
    if (updated) close();
  } finally {
    savingSectionNames.value = false;
  }
}

function resetSectionNames(scheme = storeSectionScheme.value) {
  sectionNames.value = Object.fromEntries(
    scheme?.store_sections.map((storeSection) => [
      storeSection.id,
      storeSection.name,
    ]) || [],
  );
}

function normalizedName(name: string): string {
  return name.trim().replace(/\s+/g, ' ');
}

function matchingSchemeFor(store: Store) {
  const storeName = store.name.toLowerCase();
  return groceriesStore.storeSectionSchemes.find(
    (scheme) => scheme.name.toLowerCase() === storeName,
  );
}
</script>

<style lang="scss" scoped>
.sectioning-options {
  display: grid;
  gap: 8px;
}

.sectioning-options :deep(.el-radio-button) {
  width: 100%;
}

.sectioning-options :deep(.el-radio-button__inner) {
  width: 100%;
  border: 1px solid var(--groceries-stem);
  border-radius: 8px;
  box-shadow: none;
  text-align: left;
}

.section-list {
  display: grid;
  gap: 8px;
}
</style>
