<template lang='pug'>
.project-container.mt4
  .card
    .card__body
      .project.p2
        h2.text-center.mt0.mb2(
          :class='$is_mobile_device ? "heading-3" : "heading-2"'
        )
          slot(name='title')
        .text-center.mb2(class="text-[#aaa]")
          slot(name='technologies')
        .text-center(
          v-if='$slots["links"]'
          :class='linksContainerClass'
        )
          slot(name='links')
        .text-center(
          v-if='$slots["image"]'
          :class='imageContainerClass'
        )
          slot(name='image')

        slot(name='overview')

        h3.heading-3.bold.mb2(v-if='$slots["tech-list"] && $slots["overview"]') Tech
        slot(name='tech-list')
</template>

<script lang='ts'>
export default {
  props: {
    imageContainerClass: {
      type: String,
      required: false,
      default: 'mb3',
    },
    linksContainerClass: {
      type: String,
      required: false,
      default: 'mb4',
    },
  },
};
</script>

<style lang='scss'>
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
