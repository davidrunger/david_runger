<template lang="pug">
div
  header.flex.justify-between.p-2
    div {{currentUser.email}}
  .text-center
    LogSelectorModal
    router-view(:key='$route.fullPath').m-8
    footer.mb-4 Tip: Super+k will open the log selector.
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { computed, onMounted } from 'vue';

import { bootstrap } from '@/lib/bootstrap';
import { removeQueryParams } from '@/lib/remove_query_params';
import { renderBootstrappedToasts } from '@/lib/toasts';
import { useLogsStore } from '@/logs/store';
import { useModalStore } from '@/shared/modal/store';

import LogSelectorModal from './components/LogSelectorModal.vue';
import type { Bootstrap } from './types';

const logsStore = useLogsStore();
const modalStore = useModalStore();

const { isSharedLog, selectedLog } = storeToRefs(logsStore);

const currentUser = computed(() => {
  return (bootstrap as Bootstrap).current_user;
});

removeQueryParams(); // remove query params such as `new_entry` and `auth_token`
renderBootstrappedToasts();

onMounted(() => {
  if (!isSharedLog.value) {
    // If we are viewing a specific log, we want to ensure that the log entries for that log are
    // fetched first, so delay 10ms.
    // Otherwise (i.e. if viewing index), fetch all entries immediately.
    const delayBeforeFetchingAllLogs = selectedLog.value ? 10 : 0;
    setTimeout(() => {
      logsStore.fetchAllLogEntries();
    }, delayBeforeFetchingAllLogs);
  }

  document.addEventListener('keydown', (event) => {
    if (event.key === 'k' && event.metaKey === true) {
      modalStore.showModal({ modalName: 'log-selector' });
    }
  });
});
</script>

<style lang="scss">
:root {
  --main-bg-color: #111;

  .el-button {
    --el-button-text-color: #b8babd;
    --el-button-disabled-text-color: #3d3d3d;
    --el-button-disabled-bg-color: var(--main-bg-color);
    --el-button-disabled-border-color: #2a2a2a;
  }

  .el-input__wrapper {
    background-color: var(--main-bg-color);
  }
}

body {
  background: var(--main-bg-color);
  color: #e0e0e0;
}

.log-link-container {
  // specify the height so that changing the font on hover size doesn't push other links up/down
  height: 26px;
}

a {
  color: #5aa8ed;
}

a.log-link.log-link {
  color: #e0e0e0;
  font-size: 100%;
  transition: 0.2s;

  &:hover {
    font-size: 110%;
  }
}

input[type='text'],
textarea.el-textarea__inner,
.el-input input.el-input__inner,
.el-input.is-disabled input.el-input__inner {
  background: #111;
}

textarea.el-textarea__inner {
  color: #eee;
  height: 7.5rem;
}

.el-input.is-disabled input.el-input__inner {
  color: gray;
}

.el-input input.el-input__inner {
  color: white;
}
</style>

<style lang="scss" scoped>
:deep(.el-button) {
  background: var(--main-bg-color);

  &:focus,
  &:hover {
    background: var(--main-bg-color);
  }

  &.is-disabled {
    border-color: var(--el-button-disabled-border-color);
  }
}
</style>
