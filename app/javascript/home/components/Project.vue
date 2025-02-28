<template lang="pug">
.project-container.mt-8
  .card
    .card__body
      .project.p-4
        h3.text-center.mt-0.mb-1.font-bold(
          :class='isMobileDevice() ? "text-xl" : "text-2xl"'
        )
          slot(name='title')
        .text-center.mb-1(class='text-[#aaa]')
          slot(name='technologies')
        .text-center.mb-2(v-if='$slots["links"]', :class='linksContainerClass')
          slot(name='links')
        .text-center(v-if='$slots["image"]', :class='imageContainerClass')
          slot(name='image')

        slot(name='overview')

        h4.text-xl.font-bold.mb-4(
          v-if='$slots["tech-list"] && $slots["overview"]'
        ) Tech
        slot(name='tech-list')
</template>

<script setup lang="ts">
import { isMobileDevice } from '@/lib/is_mobile_device';

defineProps({
  imageContainerClass: {
    type: String,
    required: false,
    default: 'mb-8',
  },
  linksContainerClass: {
    type: String,
    required: false,
    default: 'mb-4',
  },
});
</script>

<style lang="scss">
.card {
  border-radius: 4px;
  border: 1px solid #ebeef5;
  background-color: #fff;
  overflow: hidden;
  color: #303133;
  transition: 0.3s;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 10%);
}

.card__body {
  padding: 20px;
}

.project {
  ul {
    list-style: initial;
    padding-inline-start: 0;
    padding-left: 0;

    li {
      margin: 4px 0 4px 20px;
    }

    li:last-of-type {
      margin-bottom: 0;
    }
  }
}

img {
  max-width: 100%;
}
</style>
