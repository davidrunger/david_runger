<template lang="pug">
Modal(
  :name="modalName"
  width="85%"
  maxWidth="400px"
)
  slot
    div #[b Minutes:] {{ (timeInSeconds / 60).toFixed(1) }}
    .my-4
      h3 Rep totals
      div(v-for="(_count, exercise, index) in repTotals")
        label(:for="`${exercise}-${index}`")
          | {{ exercise }}:
          |
        input(
          :id="`${exercise}-${index}`"
          v-model.number="repTotals[exercise]"
        )
    div
      el-checkbox(v-model="publiclyViewable") Publicly viewable
    .flex.justify-around.mt-4
      el-button(
        @click="modalStore.hideModal({ modalName })"
        type="primary"
        link
      ) Cancel
      el-button(
        type="primary"
        @click="saveWorkout"
      ) Save workout
</template>

<script setup lang="ts">
import { ElButton, ElCheckbox } from 'element-plus';
import { ref } from 'vue';

import Modal from '@/components/Modal.vue';
import { useModalStore } from '@/lib/modal/store';
import { toast } from '@/lib/toasts';
import { useWorkoutsStore } from '@/workout/store';

const props = defineProps({
  repTotals: {
    type: Object,
    required: true,
  },
  timeInSeconds: {
    type: Number,
    required: true,
  },
});

const workoutsStore = useWorkoutsStore();
const modalStore = useModalStore();

const publiclyViewable = ref(false);

const modalName = 'confirm-workout';

async function saveWorkout() {
  try {
    const completedWorkout = await workoutsStore.createWorkout({
      workout: {
        publiclyViewable: publiclyViewable.value,
        repTotals: props.repTotals,
        timeInSeconds: props.timeInSeconds,
      },
    });

    toast('Workout completion logged successfully!');

    modalStore.hideModal({ modalName });
    workoutsStore.completeWorkout({ completedWorkout });
  } catch (error) {
    toast('Something went wrong', { type: 'error' });
  }
}
</script>
