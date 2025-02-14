<template lang="pug">
.text-center.pb-8
  .pt-6.pb-4
    el-switch(
      v-model='editMode'
      active-text='Edit mode'
    )
    el-switch.ml-8(
      v-model='soundEnabled'
      active-text='Sound'
    )
    .h1(v-if='timer') Time Elapsed: {{secondsAsTime(secondsElapsed)}}
    .mt-2(v-else)
      button.btn-primary(
        @click='startWorkout'
      ) Start!
  .flex.justify-center
    table
      thead
        tr
          th Set
          th(v-if='editMode') Base Time
          th(v-if='editMode') Time Adjustment
          th.time-column #[span(v-if='editMode') Final] Time
          th(v-for='exercise in exercises') {{exercise.name}}
      tbody
        tr(
          v-for='(setCount, index) in numberOfSets'
          :class='tableRowClass(index)'
        )
          td {{setCount}}
          td(v-if='editMode') {{secondsAsTime(intervalInSeconds * index)}}
          td(v-if='editMode')
            input(
              type='text'
              v-model.number='setsArray[index].timeAdjustment'
              :disabled='index <= currentRoundIndex'
            )
          td(
            :class='nextRoundCountdownClasses(index)'
          ) {{timeColumnValue(index)}}
          td(
            v-for='exercise in setsArray[index].exercises'
          )
            input(
              v-if='editMode'
              type='text'
              v-model.number='exercise.reps'
              :disabled='index <= (currentRoundIndex - 1)'
            )
            span(v-else) {{exercise.reps}}
        tr
          td
          td(v-if='editMode')
          td(v-if='editMode')
          td
          td(v-for='exercise in exercises') {{repTotalsForWorkout[assert(exercise.name)]}}
  .my-8
    button.btn-primary(@click='saveWorkout')
      | Mark workout as complete!

  ConfirmWorkoutModal(
    :timeInSeconds='secondsElapsed'
    :repTotals='repTotalsAsOfCurrentRound'
  )
</template>

<script setup lang="ts">
import { useWakeLock } from '@vueuse/core';
import { Timer } from 'easytimer.js';
import { ElSwitch } from 'element-plus';
import { cloneDeep } from 'lodash-es';
import { computed, onBeforeMount, reactive, ref, type PropType } from 'vue';

import { assert } from '@/shared/helpers';
import { useModalStore } from '@/shared/modal/store';
import type { Exercise } from '@/types';

import ConfirmWorkoutModal from './ConfirmWorkoutModal.vue';

type SetObject = {
  exercises: Array<Exercise>;
  timeAdjustment: number;
};

const props = defineProps({
  exercises: {
    type: Array as PropType<Array<Exercise>>,
    required: true,
  },
  minutes: {
    type: Number,
    required: true,
  },
  numberOfSets: {
    type: Number,
    required: true,
  },
});

const { request: requestWakeLock, release: releaseWakeLock } = useWakeLock();

const modalStore = useModalStore();

const currentRoundIndex = ref(0);
const editMode = ref(false);
const secondsElapsed = ref(0);
const soundEnabled = ref(true);
const timer = ref(null as null | Timer);

const setsArray = reactive(initialSetsArray());

const cumulativeTimeAdjustment = computed(() => {
  return (index: number, timeAdjustments: Array<number>) => {
    let cumulativeTotal = 0;
    for (let i = 0; i <= index; i++) {
      cumulativeTotal += timeAdjustments[i];
    }
    return cumulativeTotal;
  };
});

const intervalInMinutes = computed((): number => {
  if (props.numberOfSets === 1) return 0;

  return props.minutes / (props.numberOfSets - 1);
});

const intervalInSeconds = computed((): number => {
  return intervalInMinutes.value * 60;
});

const repTotalsAsOfCurrentRound = computed(() => {
  const repTotalsAsOfCurrentRound: { [key: string]: number } = {};
  for (const { name: exerciseName } of props.exercises) {
    repTotalsAsOfCurrentRound[assert(exerciseName)] = setsArray
      .slice(0, currentRoundIndex.value + 1)
      .reduce((total: number, setObject: SetObject) => {
        const exerciseObject = setObject.exercises.find(
          (exercise: Exercise) => exercise.name === exerciseName,
        );
        return total + assert(assert(exerciseObject).reps);
      }, 0);
  }
  return repTotalsAsOfCurrentRound;
});

const repTotalsForWorkout = computed(() => {
  const repTotalsForWorkout: { [key: string]: number } = {};
  for (const { name: exerciseName } of props.exercises) {
    repTotalsForWorkout[assert(exerciseName)] = setsArray.reduce(
      (total: number, setObject: SetObject) => {
        const exerciseObject = setObject.exercises.find(
          (exercise) => exercise.name === exerciseName,
        );
        return total + assert(assert(exerciseObject).reps);
      },
      0,
    );
  }
  return repTotalsForWorkout;
});

const timeAdjustments = computed((): Array<number> => {
  return setsArray.map((setObject: SetObject) => setObject.timeAdjustment);
});

const nextRoundStartAtSeconds = computed((): number => {
  return (
    Math.floor((currentRoundIndex.value + 1) * intervalInSeconds.value) +
    cumulativeTimeAdjustment.value(
      currentRoundIndex.value + 1,
      timeAdjustments.value,
    )
  );
});

const secondsUntilNextRound = computed((): number => {
  return nextRoundStartAtSeconds.value - secondsElapsed.value;
});

onBeforeMount(() => {
  window.addEventListener('beforeunload', confirmUnloadWorkoutInProgress);
});

function confirmUnloadWorkoutInProgress(event: BeforeUnloadEvent) {
  if (
    secondsElapsed.value > 0 &&
    currentRoundIndex.value < props.numberOfSets - 1 &&
    timer.value &&
    timer.value.isRunning()
  ) {
    // ask the user to confirm that they want to leave the page
    event.preventDefault();
    event.returnValue = '';
    return '';
  } else {
    // allow the user to leave without confirming
    return undefined;
  }
}

function handleSecondElapsed() {
  if (secondsElapsed.value >= nextRoundStartAtSeconds.value) {
    currentRoundIndex.value++;
    say('Go!');
  } else if ([10, 20, 30].includes(secondsUntilNextRound.value)) {
    say(`${secondsUntilNextRound.value} seconds`);
  }
}

function initialSetsArray() {
  return Array(...Array(props.numberOfSets)).map((_) => ({
    timeAdjustment: 0,
    exercises: cloneDeep(props.exercises),
  }));
}

function nextRoundCountdownClasses(index: number) {
  if (index !== currentRoundIndex.value + 1) return '';

  const classes = ['font-bold'];
  if (secondsUntilNextRound.value <= 10) {
    classes.push('text-red-600');
  } else if (secondsUntilNextRound.value <= 30) {
    classes.push('text-orange-600');
  }

  return classes;
}

function saveWorkout() {
  if (timer.value) timer.value.stop();

  releaseWakeLock();

  modalStore.showModal({ modalName: 'confirm-workout' });
}

function say(message: string, volume = 1) {
  if (!soundEnabled.value) return;

  const utterance = new SpeechSynthesisUtterance(message);
  utterance.volume = volume;
  window.speechSynthesis.speak(utterance);
}

function secondsAsTime(seconds: number) {
  if (seconds <= 0) return '0:00';

  const minutesAsDecimal = seconds / 60;
  const wholeMinutes = Math.floor(minutesAsDecimal);
  const secondsRemainder = Math.floor(seconds - 60 * wholeMinutes);
  const paddedSeconds =
    secondsRemainder < 10 ? `0${secondsRemainder}` : `${secondsRemainder}`;
  return `${wholeMinutes}:${paddedSeconds}`;
}

function startWorkout() {
  timer.value = new Timer();
  currentRoundIndex.value = 0;

  requestWakeLock('screen');

  timer.value.start();
  say('Starting workout', 0); // "say" it silently to enable speech synthesis on iOS
  timer.value.addEventListener('secondsUpdated', () => {
    if (!timer.value) return;
    secondsElapsed.value = timer.value.getTotalTimeValues().seconds;
    handleSecondElapsed();
  });
}

function tableRowClass(index: number) {
  if (index < currentRoundIndex.value) {
    return 'bg-lime-200'; // past round
  } else if (index === currentRoundIndex.value) {
    return 'bg-sky-200'; // active round
  } else {
    return ''; // future round
  }
}

function timeColumnValue(index: number) {
  if (currentRoundIndex.value + 1 === index) {
    return `-${secondsAsTime(secondsUntilNextRound.value)}`;
  } else {
    return secondsAsTime(
      intervalInSeconds.value * index +
        cumulativeTimeAdjustment.value(index, timeAdjustments.value),
    );
  }
}
</script>

<style scoped>
.time-column {
  /* fix the width because otherwise it changes as the countdown time changes */
  width: 75px;
}

table {
  border-spacing: 0;
}

table tr:first-of-type th {
  border-bottom: 1px solid gray;
}

tbody tr:last-of-type td {
  border-top: 1px solid gray;
}

td input {
  width: 50px;
}
</style>
