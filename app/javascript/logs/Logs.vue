<template lang="pug">
.text-center
  LogSelectorModal
  RouterView.m-2(:key="$route.fullPath" class="sm:m-8")
  footer.pb-4(v-if="!isSharedLogView")
    | Tip: {{ bootstrap.log_selector_keyboard_shortcut }} will open the log selector.
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { onMounted } from 'vue';

import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { useModalStore } from '@/lib/modal/store';
import { removeQueryParams } from '@/lib/remove_query_params';
import { renderBootstrappedToasts } from '@/lib/vue_toasts';
import { useLogsStore } from '@/logs/store';

import LogSelectorModal from './components/LogSelectorModal.vue';
import type { Bootstrap } from './types';

import 'element-plus/theme-chalk/dark/css-vars.css';

const bootstrap = untypedBootstrap as Bootstrap;
const logsStore = useLogsStore();
const modalStore = useModalStore();

const { isSharedLogView, selectedLog } = storeToRefs(logsStore);

removeQueryParams(); // remove query params such as `new_entry` and `auth_token`
renderBootstrappedToasts();

onMounted(() => {
  if (!isSharedLogView.value) {
    // If we are viewing a specific log, we want to ensure that the log entries for that log are
    // fetched first, so delay 10ms.
    // Otherwise (i.e. if viewing index), fetch all entries immediately.
    const delayBeforeFetchingAllLogs = selectedLog.value ? 10 : 0;
    setTimeout(() => {
      logsStore.fetchAllLogEntries();
    }, delayBeforeFetchingAllLogs);

    document.addEventListener('keydown', (event) => {
      if (
        event.key === 'k' &&
        (event.metaKey === true || event.ctrlKey === true) // Meta for macOS, Ctrl for Windows/Linux
      ) {
        event.preventDefault(); // Prevent default behavior for the shortcut
        modalStore.showModal({ modalName: 'log-selector' });
      }
    });
  }
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
