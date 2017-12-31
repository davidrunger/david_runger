<template lang='pug'>
  div
    slot(v-if='canUseWebp === null')
    img(v-else
      :src='canUseWebp ? webpImageUrl : originalImageUrl'
      :class='imageClass'
      :alt='alt'
    )
</template>

<script>
  import checkWebpSupport from 'lib/check_webp_support';

  export default {
    mounted() {
      this.originalImageUrl = this.$slots.default.find(slot => (
        slot.data.attrs.type !== 'webp'
      )).data.attrs.src;
      this.webpImageUrl = this.$slots.default.find(slot => (
        slot.data.attrs.type === 'webp'
      )).data.attrs.src;

      checkWebpSupport().then(webpIsSupported => { this.canUseWebp = webpIsSupported; });
    },

    data() {
      return {
        canUseWebp: null,
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
  };
</script>
