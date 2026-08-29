<template lang="pug">
.deleted-item-toast.flex.items-center.gap-3
  span You deleted '{{ deletedItemName }}'.
  button.deleted-item-toast__undo(@click="restoreItem") Undo
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

<style lang="scss" scoped>
.deleted-item-toast {
  justify-content: space-between;
}

.deleted-item-toast__undo {
  flex-shrink: 0;
  padding: 6px 12px;
  color: white;
  background: #96576a;
  border: none;
  border-radius: 999px;
  box-shadow: 0 3px 9px rgb(117, 64, 82, 18%);
  font-weight: 700;

  &:hover,
  &:focus {
    background: #754052;
  }
}
</style>
