<template lang="pug">
Modal(name='edit-log-sharing-settings' width='85%' maxWidth='600px' backgroundClass='bg-black')
  slot
    h3.font-bold.mb-4 Sharing
    div
      el-checkbox(
        v-model='publiclyViewable'
        @change='savePubliclyViewableChange'
      ) Publicly viewable
    div(v-if='isOwnLog && !publiclyViewable')
      el-tag(
        :key='logShare.email'
        v-for='logShare in logSharesSortedByLowercasedEmail'
        closable
        :disable-transitions='false'
        @close='handleLogShareDeletion(logShare)'
      ) {{logShare.email}}
      el-input(
        class='input-new-tag'
        v-if='inputVisible'
        v-model='inputValue'
        ref='saveTagInput'
        @keyup.enter.native='handleLogShareCreation'
        @blur='handleLogShareCreation'
      )
      el-button(v-else class='button-new-tag' size='small' @click='showInput') + Share with email
    div.mt-2 Shareable link: {{shareableUrl}}
    div
      el-button(size='small' @click='copyShareableUrlToClipboard')
        span(v-if='wasCopiedRecently') Copied!
        span(v-else) Copy to clipboard
    div.mt-2
      a.js-link(
        @click="modalStore.hideModal({ modalName: 'edit-log-sharing-settings' })"
      ) Close
</template>

<script setup lang="ts">
import { ElInput } from 'element-plus';
import { storeToRefs } from 'pinia';
import { computed, nextTick, ref } from 'vue';

import { bootstrap } from '@/lib/bootstrap';
import { useModalStore } from '@/shared/modal/store';

import { useLogsStore } from '../store';
import type { Bootstrap, LogShare } from '../types';

const logsStore = useLogsStore();
const modalStore = useModalStore();

const log = logsStore.unsafeSelectedLog;
const { isOwnLog } = storeToRefs(logsStore);

const inputValue = ref('');
const inputVisible = ref(false);
const publiclyViewable = ref(log.publicly_viewable);
const saveTagInput = ref(null);
const wasCopiedRecently = ref(false);

const logSharesSortedByLowercasedEmail = computed((): Array<LogShare> => {
  return log.log_shares
    .slice()
    .sort((a, b) => a.email.toLowerCase().localeCompare(b.email.toLowerCase()));
});

const shareableUrl = computed((): string => {
  return (
    window.location.origin +
    window.Routes.user_shared_log_path(
      (bootstrap as Bootstrap).current_user.id,
      log.slug,
    )
  );
});

function copyShareableUrlToClipboard() {
  navigator.clipboard.writeText(shareableUrl.value);

  wasCopiedRecently.value = true;

  setTimeout(() => {
    wasCopiedRecently.value = false;
  }, 1800);
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

function savePubliclyViewableChange(newPubliclyViewableState: boolean) {
  logsStore.updateLog({
    logId: log.id,
    updatedLogParams: { publicly_viewable: newPubliclyViewableState },
  });
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
