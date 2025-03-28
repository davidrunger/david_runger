<template lang="pug">
.parallax-outer.parallax-outer--desktop(v-if="!isMobileDevice()")
  .parallax-inner.parallax-inner--desktop(:class="variant")
.parallax-outer.parallax-outer--mobile(v-else)
  .parallax-inner.parallax-inner--mobile(:class="variant")
</template>

<script setup lang="ts">
import { string } from 'vue-types';

import { isMobileDevice } from '@/lib/is_mobile_device';

defineProps({
  variant: string().isRequired,
});
</script>

<style lang="scss" scoped>
.parallax-outer {
  position: relative;
}

.parallax-outer--desktop {
  height: 300px;
}

.macbook-1 {
  &::before {
    background-image: url('img/macbook-1.webp');
  }
}

.macbook-2 {
  &::before {
    background-image: url('img/macbook-2.webp');
  }
}

.parallax-inner {
  &::before {
    content: '';
  }

  // lighten the image with a semi-transparent white mask
  &::after {
    content: '';
    top: 0;
    width: 100%;
    height: 100%;
  }
}

.parallax-inner--desktop {
  width: 100%;
  position: absolute;
  clip: rect(auto, auto, auto, auto);
  height: 100%;

  &::before {
    position: fixed;
    top: 0;
    width: 100%;
    height: 100%;
    background-size: cover;
  }

  // lighten the image with a semi-transparent white mask
  &::after {
    position: fixed;
    background: rgba(255, 255, 255, 30%);
  }
}

.parallax-inner--mobile {
  width: 100%;

  &::before {
    height: 220px;
    display: block;
    background-size: cover;
  }

  // lighten the image with a semi-transparent white mask
  &::after {
    position: absolute;
    box-sizing: border-box;
    background: rgba(255, 255, 255, 60%);
    border-top: 3px solid black;
    border-bottom: 3px solid black;
  }
}
</style>
