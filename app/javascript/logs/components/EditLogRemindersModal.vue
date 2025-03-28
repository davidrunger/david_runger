<template lang="pug">
Modal(
  name="edit-log-reminder-schedule"
  width="85%"
  maxWidth="600px"
  backgroundClass="bg-black"
)
  slot
    div
      h3.font-bold.mb-4 Reminders
      .my-2(v-if="log.reminder_time_in_seconds")
        | Current setting: every {{ reminderTimeInHours }} hours
        span.ml-2
          ElButton(
            @click="cancelReminders"
            type="primary"
            link
          ) Cancel reminders

      div
        | Remind me after
        |
        input(v-model.number="numberOfTimeUnits")
        |
        |
        select(v-model="timeUnit")
          option(
            v-for="timeUnitOption in timeUnitOptions"
            :key="timeUnitOption"
          ) {{ timeUnitOption }}
        |
        | to create a log entry (if I haven't already done so).
      .flex.justify-center.mt-4
        .mr-8
          ElButton(
            @click="updateLog"
            type="primary"
            plain
          ) Save
        div
          ElButton(
            @click="modalStore.hideModal({ modalName: 'edit-log-reminder-schedule' })"
            type="primary"
            link
          ) Close
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { computed, ref } from 'vue';
import { object } from 'vue-types';

import Modal from '@/components/Modal.vue';
import { useModalStore } from '@/lib/modal/store';
import { toast } from '@/lib/toasts';
import { useLogsStore } from '@/logs/store';
import type { Log } from '@/logs/types';

const TIME_UNIT_IN_SECONDS = {
  weeks: 7 * 24 * 60 * 60,
  days: 24 * 60 * 60,
  hours: 60 * 60,
};

const props = defineProps({
  log: object<Log>().isRequired,
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
