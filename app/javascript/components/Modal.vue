<template lang="pug">
transition(name="modal")
  .modal-mask.fixed.flex.flex-col.items-center.justify-center.w-full.top-0.left-0.h-screen.z-10(
    v-if="showingModal({ modalName: name })"
    ref="mask"
    @click="handleClickMask"
  )
    .modal-container.p-8.rounded(
      :style="{ width: width, maxWidth: maxWidth }"
      :class="backgroundClass"
    )
      slot
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { onUnmounted, ref } from 'vue';
import { string } from 'vue-types';

import { useModalStore } from '@/lib/modal/store';

const props = defineProps({
  backgroundClass: string().def('bg-white'),
  name: string().isRequired,
  width: string().isRequired,
  maxWidth: string().isRequired,
});

const modalStore = useModalStore();
const mask = ref(null);

const { showingModal } = storeToRefs(modalStore);

if (!window.davidrunger.modalKeydownListenerRegistered) {
  window.addEventListener('keydown', handleKeydown);
  window.davidrunger.modalKeydownListenerRegistered = true;
}

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

function handleClickMask(event: MouseEvent) {
  // make sure we don't close the modal when clicks within the modal propagate up
  if (event.target === mask.value) {
    modalStore.hideModal({ modalName: props.name });
  }
}

function handleKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    modalStore.hideTopModal();
  }
}
</script>

<style lang="scss" scoped>
.modal-mask {
  background-color: rgba(0, 0, 0, 50%);
  transition: opacity 0.3s ease;

  // use pseudo elements to have 1/3 space above the modal and 2/3 space below the modal. so sort of
  // centered, but nudged up.
  &::before {
    content: '';
    flex-grow: 1;
  }

  &::after {
    content: '';
    flex-grow: 2;
  }
}

.modal-container {
  min-width: 300px;
  max-height: 90vh; // fallback for browsers that don't yet support `dvh` units
  max-height: 90dvh;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 33%);
  transition: all 0.3s ease;
  font-family: Helvetica, Arial, sans-serif;
  overflow: auto;
}

.modal-enter {
  opacity: 0;
}

.modal-leave-active {
  opacity: 0;
}

.modal-enter .modal-container,
.modal-leave-active .modal-container {
  transform: scale(1.1);
}
</style>
