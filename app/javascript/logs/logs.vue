<template lang='pug'>
div
  header.flex.justify-between.p1
    div {{currentUser.email}}
  .center
    LogSelector
    router-view(:key='$route.fullPath').m3
</template>

<script lang='ts'>
import { mapState } from 'pinia';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';

import { useLogsStore } from '@/logs/store';
import { useModalStore } from '@/shared/modal/store';
import LogSelector from './components/log_selector.vue';
import { Bootstrap, CurrentUser } from './types';

export default {
  components: {
    LogSelector,
  },

  computed: {
    ...mapState(useLogsStore, [
      'isSharedLog',
      'selectedLog',
    ]),

    currentUser(): CurrentUser {
      return (this.$bootstrap as Bootstrap).current_user;
    },
  },

  created() {
    if (!this.isSharedLog) {
      // If we are viewing a specific log, we want to ensure that the log entries for that log are
      // fetched first, so delay 10ms.
      // Otherwise (i.e. if viewing index), fetch all entries immediately.
      const delayBeforeFetchingAllLogs = this.selectedLog ? 10 : 0;
      setTimeout(() => {
        this.logsStore.fetchAllLogEntries();
      }, delayBeforeFetchingAllLogs);
    }

    document.addEventListener('keydown', (event) => {
      if ((event.key === 'k') && (event.metaKey === true)) {
        this.modalStore.showModal({ modalName: 'log-selector' });
      }
    });

    // display any initial toast messages
    const toastMessages = (this.$bootstrap as Bootstrap).toast_messages;
    if (toastMessages) {
      for (const message of toastMessages) {
        Toastify({
          text: message,
          position: 'center',
          duration: 1800,
        }).showToast();
      }
    }

    // remove any query params that might be present (e.g. `new_entry` and `auth_token`)
    window.history.replaceState({}, document.title, window.location.pathname);
  },

  data() {
    return {
      logsStore: useLogsStore(),
      modalStore: useModalStore(),
    };
  },
};
</script>

<style lang='scss'>
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

a.log-link {
  color: #e0e0e0;
  font-size: 100%;
  transition: 0.2s;

  &:hover {
    font-size: 110%;
  }
}

input[type="text"],
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

<style lang='scss' scoped>
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
