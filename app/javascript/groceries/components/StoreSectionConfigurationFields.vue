<template lang="pug">
ElRadioGroup.sectioning-options(
  :modelValue="mode"
  :aria-label="`Section setup for ${store.name}`"
  @update:modelValue="emit('update:mode', $event)"
)
  ElRadio(value="new") Create a new layout
  ElRadio(
    v-if="schemes.length > 0"
    value="existing"
  ) Use an existing layout
  ElRadio(value="none") This store doesn't need sections

label.configuration-field(v-if="mode === 'new'")
  span.mb-1.block.text-sm.font-semibold Layout name
  ElInput(
    :modelValue="newSchemeName"
    @update:modelValue="emit('update:newSchemeName', $event)"
    @keyup.enter="emit('submit')"
  )

label.configuration-field(v-else-if="mode === 'existing'")
  span.mb-1.block.text-sm.font-semibold Layout
  ElSelect.w-full(
    :modelValue="selectedSchemeId"
    placeholder="Choose a layout"
    @update:modelValue="emit('update:selectedSchemeId', $event)"
  )
    ElOption(
      v-for="scheme in schemes"
      :key="scheme.id"
      :label="scheme.name"
      :value="scheme.id"
    )

p.configuration-field.text-sm.text-neutral-600(v-else) {{ noneMessage }}
</template>

<script setup lang="ts">
import {
  ElInput,
  ElOption,
  ElRadio,
  ElRadioGroup,
  ElSelect,
} from 'element-plus';

import type { Store, StoreSectionScheme } from '@/types';

type SectionConfigurationMode = 'existing' | 'new' | 'none';

defineProps<{
  mode: SectionConfigurationMode;
  newSchemeName: string;
  noneMessage: string;
  schemes: Array<StoreSectionScheme>;
  selectedSchemeId?: number;
  store: Store;
}>();

const emit = defineEmits<{
  submit: [];
  'update:mode': [mode: SectionConfigurationMode];
  'update:newSchemeName': [newSchemeName: string];
  'update:selectedSchemeId': [selectedSchemeId: number | undefined];
}>();
</script>

<style lang="scss" scoped>
.sectioning-options {
  display: grid;
  gap: 8px;
}

.sectioning-options :deep(.el-radio) {
  height: auto;
  margin-right: 0;
}

.configuration-field {
  display: block;
  margin-top: 12px;
}
</style>
