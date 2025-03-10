<template lang="pug">
Modal(
  name="edit-log-sharing-settings"
  width="85%"
  maxWidth="600px"
  backgroundClass="bg-black"
)
  slot
    h3.font-bold.mb-4 Sharing
    div
      el-checkbox(
        v-model="publiclyViewable"
        @change="savePubliclyViewableChange"
      ) Publicly viewable
    div(v-if="!publiclyViewable")
      el-tag(
        :key="logShare.email"
        v-for="logShare in logSharesSortedByLowercasedEmail"
        closable
        :disable-transitions="false"
        @close="handleLogShareDeletion(logShare)"
      ) {{ logShare.email }}
      el-input.input-new-tag(
        v-if="inputVisible"
        v-model="inputValue"
        ref="saveTagInput"
        @keyup.enter.native="handleLogShareCreation"
        @blur="handleLogShareCreation"
      )
      el-button.button-new-tag(
        v-else
        size="small"
        @click="showInput"
      ) + Share with email
    .mt-2 Shareable link: {{ shareableUrl }}
    div
      el-button(
        size="small"
        @click="copyShareableUrlToClipboard"
      )
        span(v-if="wasCopiedRecently") Copied!
        span(v-else) Copy to clipboard
    .mt-2
      a.js-link(
        @click="modalStore.hideModal({ modalName: 'edit-log-sharing-settings' })"
      ) Close
</template>

<script setup lang="ts">
import {
  ElButton,
  ElCheckbox,
  ElInput,
  ElTag,
  type CheckboxValueType,
} from 'element-plus';
import { computed, nextTick, ref } from 'vue';

import Modal from '@/components/Modal.vue';
import { bootstrap } from '@/lib/bootstrap';
import { assert } from '@/lib/helpers';
import { useModalStore } from '@/lib/modal/store';
import { useLogsStore } from '@/logs/store';
import type { Bootstrap } from '@/logs/types';
import { user_shared_log_path } from '@/rails_assets/routes';
import type { LogShare } from '@/types';

const logsStore = useLogsStore();
const modalStore = useModalStore();

const log = assert(logsStore.selectedLog);

const inputValue = ref('');
const inputVisible = ref(false);
const publiclyViewable = ref(log.publicly_viewable);
const saveTagInput = ref(null);
const wasCopiedRecently = ref(false);

const logSharesSortedByLowercasedEmail = computed((): Array<LogShare> => {
  return assert(log.log_shares)
    .slice()
    .sort((a, b) => a.email.toLowerCase().localeCompare(b.email.toLowerCase()));
});

const shareableUrl = computed((): string | null => {
  const currentUser = (bootstrap as Bootstrap).current_user;

  if (currentUser) {
    return (
      window.location.origin + user_shared_log_path(currentUser.id, log.slug)
    );
  } else {
    return null;
  }
});

function copyShareableUrlToClipboard() {
  if (shareableUrl.value) {
    navigator.clipboard.writeText(shareableUrl.value);

    wasCopiedRecently.value = true;

    setTimeout(() => {
      wasCopiedRecently.value = false;
    }, 1800);
  }
}

function handleLogShareDeletion(logShare: LogShare) {
  logsStore.deleteLogShare({
    log,
    logShareId: logShare.id,
  });
}

function handleLogShareCreation() {
  if (inputValue.value) {
    logsStore.addLogShare({
      logId: log.id,
      newLogShareEmail: inputValue.value,
    });
  }
  inputVisible.value = false;
  inputValue.value = '';
}

function savePubliclyViewableChange(
  newPubliclyViewableState: CheckboxValueType,
) {
  if (typeof newPubliclyViewableState === 'boolean') {
    logsStore.updateLog({
      logId: log.id,
      updatedLogParams: { publicly_viewable: newPubliclyViewableState },
    });
  }
}

function showInput() {
  inputVisible.value = true;
  nextTick(() => {
    if (saveTagInput.value) {
      (saveTagInput.value as typeof ElInput).$refs.input.focus();
    }
  });
}
</script>

<style scoped lang="scss">
.el-tag:not(:first-of-type),
.button-new-tag {
  margin-top: 10px;
}

.el-tag + .el-tag,
.el-tag + .button-new-tag {
  margin-left: 10px;
}
</style>
