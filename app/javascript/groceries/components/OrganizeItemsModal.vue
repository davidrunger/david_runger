<template lang="pug">
Modal(
  :name="modalName"
  width="85%"
  maxWidth="560px"
)
  .organize-items-modal
    template(v-if="showingSetup")
      h3.mb-2.font-bold Set up store sections
      p.mb-4.text-sm.text-neutral-600 Choose how you want to organize items for each store before assigning sections.

      .setup-store.mb-5(
        v-for="store in storesNeedingSetup"
        :key="store.id"
      )
        h4.flex.items-center.gap-1.font-semibold
          HeartFilledIcon.text-red-500(
            v-if="!store.own_store"
            size="16"
          )
          span {{ store.name }}

        StoreSectionConfigurationFields.mt-2(
          v-model:mode="setupModes[store.id]"
          v-model:newSchemeName="newSchemeNames[store.id]"
          v-model:selectedSchemeId="selectedSchemeIds[store.id]"
          :noneMessage="'Items from this store will stay ungrouped. You can change this later.'"
          :schemes="groceriesStore.sortedStoreSectionSchemes"
          :store="store"
        )

      template(v-if="storesAlreadySetUp.length > 0")
        h4.mb-2.font-semibold Already set up
        .configured-store.mb-5(
          v-for="store in storesAlreadySetUp"
          :key="store.id"
        )
          h5.flex.items-center.gap-1.font-semibold
            HeartFilledIcon.text-red-500(
              v-if="!store.own_store"
              size="16"
            )
            span {{ store.name }}
          p.mt-2.text-sm.text-neutral-600(
            v-if="store.section_configuration?.sectioning_enabled"
          ) Using the {{ store.section_configuration?.store_section_scheme?.name }} layout.
          p.mt-2.text-sm.text-neutral-600(v-else) Items from this store will stay ungrouped.

      p.mb-3.text-sm.text-red-700(v-if="setupError") {{ setupError }}

      .mt-5.flex.justify-around
        ElButton(
          link
          type="primary"
          @click="close"
        ) Cancel
        ElButton(
          type="primary"
          :loading="savingSetup"
          @click="saveSetup"
        ) Continue

    template(v-else)
      h3.mb-2.font-bold Organize items
      p.mb-4.text-sm.text-neutral-600 Assign a section where it will help on your next trip. Leave any item unselected to organize it later.

      template(v-if="classificationTargets.length > 0")
        .organize-item.py-3(
          v-for="target in classificationTargets"
          :key="target.key"
        )
          .mb-2.flex.items-center.gap-1.font-semibold
            span {{ target.item.name }}
            ElTooltip(
              v-if="!target.store.own_store"
              content="Spouse item"
              placement="top"
            )
              HeartFilledIcon.text-red-500(size="16")
          p.mb-2.text-sm.text-neutral-600 {{ target.store.name }}

          label.block
            span.sr-only Section for {{ target.item.name }} at {{ target.store.name }}
            ElSelect.w-full(
              v-model="selectedSectionIds[target.key]"
              clearable
              placeholder="Choose a section"
            )
              ElOption(
                v-for="storeSection in target.scheme.store_sections"
                :key="storeSection.id"
                :label="storeSection.name"
                :value="storeSection.id"
              )

          form.mt-2.flex.gap-2(@submit.prevent="addSection(target)")
            label.flex-1
              span.sr-only New section for {{ target.store.name }}
              ElInput(
                v-model="newSectionNames[target.key]"
                placeholder="Add a section"
              )
            ElButton(
              native-type="submit"
              type="primary"
              :loading="addingSectionForTarget === target.key"
            ) Add

      .multi-store-items.mt-5(v-if="multiStoreItems.length > 0")
        h4.mb-2.font-semibold Available at multiple stores
        p.mb-2.text-sm.text-neutral-600 These items need different section choices for more than one selected store. Organize them from the item menu when you need them.
        ul
          li(
            v-for="item in multiStoreItems"
            :key="item.id"
          ) {{ item.name }}

      p.text-sm.text-neutral-600(
        v-if="classificationTargets.length === 0 && multiStoreItems.length === 0"
      ) Everything in this group is already organized, or these stores do not use sections.

      .mt-5.flex.justify-around
        ElButton(
          link
          type="primary"
          @click="close"
        ) Skip for now
        ElButton(
          type="primary"
          :loading="savingAssignments"
          @click="saveAssignments"
        ) Done
</template>

<script setup lang="ts">
import { ElButton, ElInput, ElOption, ElSelect, ElTooltip } from 'element-plus';
import { computed, ref, watch } from 'vue';
import { HeartFilledIcon } from 'vue-tabler-icons';

import Modal from '@/components/Modal.vue';
import { helpers, useGroceriesStore } from '@/groceries/store';
import {
  matchingSchemeFor,
  normalizedName,
} from '@/groceries/storeSectionHelpers';
import type { Item } from '@/groceries/types';
import { useModalStore } from '@/lib/modal/store';
import type { Store, StoreSectionScheme } from '@/types';

import StoreSectionConfigurationFields from './StoreSectionConfigurationFields.vue';

interface ClassificationTarget {
  item: Item;
  key: string;
  scheme: StoreSectionScheme;
  store: Store;
}

const props = defineProps<{
  items: Array<Item>;
  stores: Array<Store>;
}>();

const modalName = 'organize-grocery-items';
const groceriesStore = useGroceriesStore();
const modalStore = useModalStore();
const addingSectionForTarget = ref<string>();
const newSchemeNames = ref<Record<number, string>>({});
const newSectionNames = ref<Record<string, string>>({});
const savingAssignments = ref(false);
const savingSetup = ref(false);
const selectedSchemeIds = ref<Record<number, number | undefined>>({});
const selectedSectionIds = ref<Record<string, number | undefined>>({});
const setupError = ref('');
const setupModes = ref<Record<number, 'existing' | 'new' | 'none'>>({});
const showingSetup = ref(false);

const showingModal = computed(() => modalStore.showingModal({ modalName }));
const storesNeedingSetup = computed(() => {
  return props.stores.filter((store) => !store.section_configuration);
});
const storesAlreadySetUp = computed(() => {
  return props.stores.filter((store) => store.section_configuration);
});
const uniqueItems = computed(() => {
  const itemsById = new Map(props.items.map((item) => [item.id, item]));
  return helpers.sortByName([...itemsById.values()]);
});
const classificationTargets = computed((): Array<ClassificationTarget> => {
  return uniqueItems.value.flatMap((item) => {
    const targets = unassignedTargetsForItem(item);
    return targets.length === 1 ? targets : [];
  });
});
const multiStoreItems = computed(() => {
  return uniqueItems.value.filter(
    (item) => unassignedTargetsForItem(item).length > 1,
  );
});

watch(
  showingModal,
  async (showing) => {
    if (!showing) return;

    await groceriesStore.pullStoreSectionSchemes();
    reset();
  },
  { immediate: true },
);

function close() {
  modalStore.hideModal({ modalName });
}

function reset() {
  newSchemeNames.value = Object.fromEntries(
    storesNeedingSetup.value.map((store) => [store.id, store.name]),
  );
  newSectionNames.value = {};
  selectedSchemeIds.value = Object.fromEntries(
    storesNeedingSetup.value.flatMap((store) => {
      const matchingScheme = matchingSchemeFor(
        store,
        groceriesStore.storeSectionSchemes,
      );
      return matchingScheme ? [[store.id, matchingScheme.id]] : [];
    }),
  );
  selectedSectionIds.value = {};
  setupError.value = '';
  setupModes.value = Object.fromEntries(
    storesNeedingSetup.value.map((store) => [
      store.id,
      matchingSchemeFor(store, groceriesStore.storeSectionSchemes) ? 'existing'
      : 'new',
    ]),
  );
  showingSetup.value = storesNeedingSetup.value.length > 0;
}

async function addSection(target: ClassificationTarget) {
  const name = normalizedName(newSectionNames.value[target.key] || '');
  if (!name) return;

  addingSectionForTarget.value = target.key;
  try {
    if (
      await groceriesStore.createStoreSection({
        storeSectionScheme: target.scheme,
        name,
      })
    ) {
      const section =
        target.store.section_configuration?.store_section_scheme?.store_sections.find(
          (storeSection) => storeSection.name === name,
        );
      if (section) selectedSectionIds.value[target.key] = section.id;
      newSectionNames.value[target.key] = '';
    }
  } finally {
    addingSectionForTarget.value = undefined;
  }
}

function configurationModeFor(store: Store) {
  return setupModes.value[store.id] || 'new';
}

async function saveAssignments() {
  savingAssignments.value = true;
  try {
    const updates = classificationTargets.value.flatMap((target) => {
      const sectionId = selectedSectionIds.value[target.key];
      const storeSection = target.scheme.store_sections.find(
        (section) => section.id === sectionId,
      );
      if (!storeSection) return [];

      return [{ item: target.item, store: target.store, storeSection }];
    });
    if (await groceriesStore.updateItemSectionAssignments({ updates })) close();
  } finally {
    savingAssignments.value = false;
  }
}

async function saveSetup() {
  setupError.value = '';
  savingSetup.value = true;

  try {
    const setupSelections = storesNeedingSetup.value.map((store) => ({
      mode: configurationModeFor(store),
      name: normalizedName(newSchemeNames.value[store.id] || ''),
      schemeId: selectedSchemeIds.value[store.id],
      store,
    }));

    for (const { mode, name, schemeId, store } of setupSelections) {
      if (mode === 'new' && !name) {
        setupError.value = `Enter a layout name for ${store.name}.`;
        return;
      }
      if (mode === 'existing' && !schemeId) {
        setupError.value = `Choose a layout for ${store.name}.`;
        return;
      }
    }

    const createdSchemeIdsByName = new Map<string, number>();
    for (const selection of setupSelections) {
      const { mode, name, store } = selection;
      if (mode === 'none') {
        if (
          !(await groceriesStore.updateStoreSectionConfiguration({
            store,
            sectioningEnabled: false,
            storeSectionSchemeId: null,
          }))
        )
          return;
        continue;
      }

      let schemeId = selection.schemeId;
      if (mode === 'new') {
        const normalizedKey = name.toLowerCase();
        schemeId = createdSchemeIdsByName.get(normalizedKey);
        if (!schemeId) {
          const createdScheme = await groceriesStore.createStoreSectionScheme({
            name,
          });
          if (!createdScheme) return;

          schemeId = createdScheme.id;
          createdSchemeIdsByName.set(normalizedKey, schemeId);
        }
      }

      if (!schemeId) return;

      if (
        !(await groceriesStore.updateStoreSectionConfiguration({
          store,
          sectioningEnabled: true,
          storeSectionSchemeId: schemeId,
        }))
      )
        return;
    }

    showingSetup.value = false;
    if (
      classificationTargets.value.length === 0 &&
      multiStoreItems.value.length === 0
    ) {
      close();
    }
  } finally {
    savingSetup.value = false;
  }
}

function unassignedTargetsForItem(item: Item): Array<ClassificationTarget> {
  return props.stores.flatMap((store) => {
    if (!item.store_ids.includes(store.id)) return [];

    const scheme = store.section_configuration?.store_section_scheme;
    const assigned = store.item_section_assignments.some(
      (assignment) => assignment.item_id === item.id,
    );
    if (!store.section_configuration?.sectioning_enabled || !scheme || assigned)
      return [];

    return [{ item, key: `${store.id}-${item.id}`, scheme, store }];
  });
}
</script>

<style lang="scss" scoped>
.setup-store,
.configured-store,
.organize-item,
.multi-store-items {
  padding: 12px;
  background: rgb(223, 231, 215, 42%);
  border: 1px solid rgb(198, 203, 185, 65%);
  border-radius: 12px;
}

.organize-item + .organize-item {
  margin-top: 10px;
}
</style>
