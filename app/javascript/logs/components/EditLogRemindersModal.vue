<template lang="pug">
Modal(name='edit-log-reminder-schedule' width='85%' maxWidth='600px' backgroundClass='bg-black')
  slot
    div
      h3.font-bold.mb-4 Reminders
      div.my-2(v-if='log.reminder_time_in_seconds')
        | Current setting: every {{reminderTimeInHours}} hours
        span.ml-2
          el-button(
            @click="cancelReminders"
            type='primary'
            link
          ) Cancel reminders

      div
        | Remind me after
        |
        input(v-model.number='numberOfTimeUnits')
        |
        |
        select(v-model='timeUnit')
          option(v-for='timeUnit in timeUnitOptions') {{timeUnit}}
        |
        | to create a log entry (if I haven't already done so).
      div.flex.justify-center.mt-4
        .mr-8
          el-button(
            @click='updateLog'
            type='primary'
            plain
          ) Save
        div
          el-button(
            @click="modalStore.hideModal({ modalName: 'edit-log-reminder-schedule' })"
            type='primary'
            link
          ) Close
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { computed, ref, type PropType } from 'vue';

import { toast } from '@/lib/toasts';
import { useLogsStore } from '@/logs/store';
import type { Log } from '@/logs/types';
import { useModalStore } from '@/shared/modal/store';

const TIME_UNIT_IN_SECONDS = {
  weeks: 7 * 24 * 60 * 60,
  days: 24 * 60 * 60,
  hours: 60 * 60,
};

const props = defineProps({
  log: {
    type: Object as PropType<Log>,
    required: true,
  },
});

const logsStore = useLogsStore();
const modalStore = useModalStore();
const numberOfTimeUnits = ref(null);
const timeUnit = ref(null);

const formSelectedReminderTimeInSeconds = computed((): number | null => {
  if (!numberOfTimeUnits.value || !timeUnit.value) return null;

  return numberOfTimeUnits.value * TIME_UNIT_IN_SECONDS[timeUnit.value];
});

const reminderTimeInHours = computed((): string => {
  const reminderTimeInSeconds = props.log.reminder_time_in_seconds;

  if (reminderTimeInSeconds) {
    return (reminderTimeInSeconds / (60 * 60)).toFixed();
  } else {
    return '[none]';
  }
});

const timeUnitOptions = computed(() => {
  return Object.keys(TIME_UNIT_IN_SECONDS);
});

async function cancelReminders() {
  hideReminderSchedulingModal();

  await logsStore.updateLog({
    logId: props.log.id,
    updatedLogParams: { reminder_time_in_seconds: null },
  });

  toast('Reminders cancelled!');
}

function hideReminderSchedulingModal() {
  modalStore.hideModal({ modalName: 'edit-log-reminder-schedule' });
}

async function updateLog() {
  hideReminderSchedulingModal();

  await logsStore.updateLog({
    logId: props.log.id,
    updatedLogParams: {
      reminder_time_in_seconds: formSelectedReminderTimeInSeconds.value,
    },
  });

  toast('Reminder time updated!');
}
</script>

<style scoped>
input {
  width: 30px;
}

input,
select {
  background: inherit;
}
</style>
