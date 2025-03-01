<template lang="pug">
div
  | You deleted '{{ deletedItemName }}'.
  |
  button.btn-primary(@click="restoreItem") Undo
</template>

<script setup lang="ts">
import { http } from '@/shared/http';

const props = defineProps({
  deletedItemName: {
    type: String,
    required: true,
  },

  restoreItemPath: {
    type: String,
    required: true,
  },
});

function restoreItem() {
  http.post(props.restoreItemPath);
}
</script>
