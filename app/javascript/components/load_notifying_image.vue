<template lang='pug'>
div
  slot
</template>

<script>
import { emit } from '@/lib/event_bus';

let image;

export default {
  methods: {
    emitGlobalLoadEvent() {
      emit('load-notifying-image:image-loaded');
    },
  },

  mounted() {
    image = this.$el.querySelector('img');
    // https://stackoverflow.com/a/24201249/4009384
    if (image.complete) {
      this.emitGlobalLoadEvent();
    } else {
      image.addEventListener('load', this.emitGlobalLoadEvent);
    }
  },

  unmounted() {
    image.removeEventListener('load', this.emitGlobalLoadEvent);
  },
};
</script>
