<template lang='pug'>
div
  h3.bold.mb2 Reminders
  div.my1(v-if='log.reminder_time_in_seconds')
    | Current setting: every {{this.log.reminder_time_in_seconds | secondsAsHours}} hours
    span.ml1
      el-button(
        @click="cancelReminders"
        type='text'
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
  div.flex.justify-center.mt2
    .mr2
      el-button(
        @click='updateLog'
        type='primary'
        plain
      ) Save
    div
      el-button(
        @click="$store.commit('hideModal', { modalName: 'edit-log-reminder-schedule' })"
        type='text'
      ) Close
</template>

<script>
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';

const TIME_UNIT_IN_SECONDS = {
  weeks: 7 * 24 * 60 * 60,
  days: 24 * 60 * 60,
  hours: 60 * 60,
};

export default {
  computed: {
    formSelectedReminderTimeInSeconds() {
      if (!this.numberOfTimeUnits || !this.timeUnit) return undefined;

      return this.numberOfTimeUnits * TIME_UNIT_IN_SECONDS[this.timeUnit];
    },

    timeUnitOptions() {
      return Object.keys(TIME_UNIT_IN_SECONDS);
    },
  },

  data() {
    return {
      numberOfTimeUnits: null,
      timeUnit: null,
    };
  },

  filters: {
    secondsAsHours(seconds) {
      return (seconds / (60 * 60)).toFixed();
    },
  },

  methods: {
    cancelReminders() {
      this.hideReminderSchedulingModal();
      this.$store.dispatch('updateLog', {
        logId: this.log.id,
        updatedLogParams: { reminder_time_in_seconds: null },
      }).then(() => {
        Toastify({
          text: 'Reminders cancelled!',
          className: 'success',
          position: 'center',
          duration: 1800,
        }).showToast();
      });
    },

    hideReminderSchedulingModal() {
      this.$store.commit('hideModal', { modalName: 'edit-log-reminder-schedule' });
    },

    updateLog() {
      this.hideReminderSchedulingModal();
      this.$store.dispatch('updateLog', {
        logId: this.log.id,
        updatedLogParams: { reminder_time_in_seconds: this.formSelectedReminderTimeInSeconds },
      }).then(() => {
        const reminderHours =
          this.$options.filters.secondsAsHours(this.log.reminder_time_in_seconds);
        Toastify({
          text: `Reminder time updated to ${reminderHours} hours!`,
          className: 'success',
          position: 'center',
          duration: 1800,
        }).showToast();
      });
    },
  },

  props: {
    log: {
      type: Object,
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
