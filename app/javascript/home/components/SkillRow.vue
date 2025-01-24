<template lang="pug">
tr
  td.text-center
    slot(v-if='$slots.image' name='image')
    i(v-else :class='devIconClass')
  td {{ name }}
  td
    slot(v-if='$slots.details' name='details')
    span(v-else) {{ details }}
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps({
  name: {
    type: String,
    required: true,
  },
  details: {
    type: String,
    required: true,
  },
  iconIdentifier: {
    type: String,
    required: false,
    default: null,
  },
  plainIcon: {
    type: Boolean,
    default: true,
  },
  coloredIcon: {
    type: Boolean,
    default: true,
  },
  wordmarkedIcon: {
    type: Boolean,
    default: true,
  },
});

const devIconClass = computed(() => {
  const iconIdentifier = props.iconIdentifier || props.name.toLowerCase();
  let iconClass = `devicon-${iconIdentifier}`;
  if (props.plainIcon) iconClass = `${iconClass}-plain`;
  if (props.wordmarkedIcon) iconClass = `${iconClass}-wordmark`;
  if (props.coloredIcon) iconClass = `${iconClass} colored`;

  return iconClass;
});
</script>

<style lang="scss" scoped>
i[class^='devicon-'] {
  font-size: 65px;

  @media (width <= 550px) {
    font-size: 45px;
  }
}

tr:not(:first-child) td {
  border-top: 1px solid var(--gray-lighter);
}

td {
  padding: 10px;
  height: 75px;
  vertical-align: middle;

  :deep(img) {
    max-width: 65px;
  }

  @media (width <= 550px) {
    padding: 10px 4px;

    :deep(img) {
      width: 50px;
    }
  }
}

td:nth-child(2) {
  font-weight: bold;
  text-align: center;
}
</style>
