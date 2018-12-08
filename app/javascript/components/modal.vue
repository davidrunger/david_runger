<template lang='pug'>
transition(name='modal')
  div.modal-mask.fixed.flex.flex-column.items-center.justify-center.col-12.top-0.left-0.vh-100.z1(
    ref='mask'
    @click='closeModal'
  )
    div.modal-container.p3.bg-white.rounded(:style='{ width: width, maxWidth: maxWidth }')
      slot
</template>

<script>
import keycode from 'keycode';

export default {
  methods: {
    closeModal(e) {
      // make sure we don't close the modal when clicks within the modal propagate up
      if (e.target === this.$refs.mask) {
        this.$store.commit('setShowModal', { value: false });
      }
    },

    handleKeydown(e) {
      if (e.which === keycode('escape')) this.$store.commit('setShowModal', { value: false });
    },
  },

  destroyed() {
    window.removeEventListener('keydown', this.handleKeydown);
  },

  mounted() {
    window.addEventListener('keydown', this.handleKeydown);
  },

  props: {
    width: {
      type: String,
      required: true,
    },
    maxWidth: {
      type: String,
      required: true,
    },
  },
};
</script>

<style lang='scss' scoped>
.modal-mask {
  background-color: rgba(0, 0, 0, 0.5);
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
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
  transition: all 0.3s ease;
  font-family: Helvetica, Arial, sans-serif;
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
