<template lang="pug">
div
  | You deleted '{{ deletedItemName }}'.
  |
  button.btn-primary(@click="restoreItem") Undo
</template>

<script setup lang="ts">
import { string } from 'vue-types';

import { http } from '@/lib/http';

const props = defineProps({
  deletedItemName: string().isRequired,
  restoreItemPath: string().isRequired,
});

function restoreItem() {
  http.post(props.restoreItemPath);
}
</script>
