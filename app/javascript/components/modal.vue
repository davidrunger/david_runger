<template lang='pug'>
transition(name='modal' v-if="showingModal({ modalName: name })")
  div.modal-mask.fixed.flex.flex-column.items-center.justify-center.col-12.top-0.left-0.vh-100.z1(
    ref='mask'
    @click='handleClickMask'
  )
    div.modal-container.p3.rounded(
      :style='{ width: width, maxWidth: maxWidth }'
      :class='backgroundClass'
    )
      slot
</template>

<script>
import { mapGetters } from 'vuex';
import keycode from 'keycode';

export default {
  computed: {
    ...mapGetters([
      'showingModal',
    ]),
  },

  methods: {
    handleClickMask(event) {
      // make sure we don't close the modal when clicks within the modal propagate up
      if (event.target === this.$refs.mask) {
        this.$store.commit('hideModal', { modalName: this.name });
      }
    },

    handleKeydown(e) {
      if (e.which === keycode('escape')) {
        this.$store.commit('hideTopModal');
      }
    },
  },

  created() {
    // since there might be multiple modals, ensure we only register the keydown listener once
    if (!window.davidrunger.modalKeydownListenerRegistered) {
      window.addEventListener('keydown', this.handleKeydown);
      window.davidrunger.modalKeydownListenerRegistered = true;
    }
  },

  unmounted() {
    window.removeEventListener('keydown', this.handleKeydown);
  },

  props: {
    backgroundClass: {
      type: String,
      required: false,
      default: 'bg-white',
    },
    name: {
      type: String,
      required: true,
    },
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
