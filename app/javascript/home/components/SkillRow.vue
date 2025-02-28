<template lang="pug">
tr
  td
    .svg-container(v-html='svgContent')
  td {{ name }}
  td {{ details }}
</template>

<script setup lang="ts">
import { ref, watchEffect } from 'vue';

const props = defineProps({
  name: {
    type: String,
    required: true,
  },
  details: {
    type: String,
    required: true,
  },
});

const svgContent = ref<null | string>(null);

const svgFiles = import.meta.glob('img/dev-icons/*.svg', {
  query: '?raw',
  import: 'default',
});

watchEffect(() => {
  async function loadSvg() {
    const fileName = props.name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
    const filePath = `../assets/images/dev-icons/${fileName}.svg`;

    const svgFileForPath = svgFiles[filePath];

    if (svgFileForPath) {
      const fileSvgContent = await svgFileForPath();

      if (typeof fileSvgContent === 'string') {
        svgContent.value = fileSvgContent;
      }
    }
  }

  loadSvg();
});
</script>

<style lang="scss">
/* Make SVG fill its container. Must be unscoped because it's set via v-html. */
.svg-container svg {
  width: 100%;
  height: 100%;
}
</style>

<style lang="scss" scoped>
$icon-size-normal: 50px;
$icon-size-small: 42px;

.svg-container {
  height: $icon-size-normal;
  width: $icon-size-normal;

  @media (width <= 550px) {
    height: $icon-size-small;
    width: $icon-size-small;
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
