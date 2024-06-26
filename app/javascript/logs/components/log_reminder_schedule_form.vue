<template lang="pug">
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

<script lang="ts">
import Toastify from 'toastify-js';
import { PropType } from 'vue';

import { useLogsStore } from '@/logs/store';
import { Log } from '@/logs/types';
import { useModalStore } from '@/shared/modal/store';

const TIME_UNIT_IN_SECONDS = {
  weeks: 7 * 24 * 60 * 60,
  days: 24 * 60 * 60,
  hours: 60 * 60,
};

export default {
  computed: {
    formSelectedReminderTimeInSeconds(): number | null {
      if (!this.numberOfTimeUnits || !this.timeUnit) return null;

      return this.numberOfTimeUnits * TIME_UNIT_IN_SECONDS[this.timeUnit];
    },

    reminderTimeInHours(): string {
      return (this.log.reminder_time_in_seconds / (60 * 60)).toFixed();
    },

    timeUnitOptions() {
      return Object.keys(TIME_UNIT_IN_SECONDS);
    },
  },

  data() {
    return {
      logsStore: useLogsStore(),
      modalStore: useModalStore(),
      numberOfTimeUnits: null,
      timeUnit: null,
    };
  },

  methods: {
    async cancelReminders() {
      this.hideReminderSchedulingModal();

      await this.logsStore.updateLog({
        logId: this.log.id,
        updatedLogParams: { reminder_time_in_seconds: null },
      });

      Toastify({
        text: 'Reminders cancelled!',
        position: 'center',
        duration: 1800,
      }).showToast();
    },

    hideReminderSchedulingModal() {
      this.modalStore.hideModal({ modalName: 'edit-log-reminder-schedule' });
    },

    async updateLog() {
      this.hideReminderSchedulingModal();

      await this.logsStore.updateLog({
        logId: this.log.id,
        updatedLogParams: {
          reminder_time_in_seconds: this.formSelectedReminderTimeInSeconds,
        },
      });

      Toastify({
        text: 'Reminder time updated!',
        position: 'center',
        duration: 1800,
      }).showToast();
    },
  },

  props: {
    log: {
      type: Object as PropType<Log>,
      required: true,
    },
  },
};
</script>

<style scoped>
input {
  width: 30px;
}
</style>
