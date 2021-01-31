<template lang='pug'>
div
  slot(v-if='(canUseWebp === null) || (lazy && !mayRenderLazyImages)')
  img(v-else
    :src='(canUseWebp && webpImageUrl) ? webpImageUrl : originalImageUrl'
    :class='imageClass'
    :alt='alt'
    @load='emitGlobalLoadEvent'
  )
</template>

<script>
import whenDomReady from 'when-dom-ready';

import checkWebpSupport from 'lib/check_webp_support';
import { emit } from 'lib/event_bus';

export default {
  mounted() {
    const nonWebpSource = this.$slots.default().find(slot => (
      slot.props.type !== 'webp'
    ));
    this.originalImageUrl = nonWebpSource.props.src;

    const webpSource = this.$slots.default().find(slot => (
      slot.props.type === 'webp'
    ));
    this.webpImageUrl = webpSource ? webpSource.props.src : null;

    checkWebpSupport().then(webpIsSupported => { this.canUseWebp = webpIsSupported; });
    whenDomReady().then(() => { this.mayRenderLazyImages = true; });
  },

  data() {
    return {
      canUseWebp: null,
      mayRenderLazyImages: false,
      originalImageUrl: null,
      webpImageUrl: null,
    };
  },

  props: {
    alt: {
      type: String,
      required: true,
    },
    imageClass: {
      type: String,
      required: false,
    },
    lazy: {
      type: Boolean,
      required: false,
      default: false,
    },
  },

  methods: {
    emitGlobalLoadEvent() {
      emit('performant-image:image-loaded');
    },
  },
};
</script>
