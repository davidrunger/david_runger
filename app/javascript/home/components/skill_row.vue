<template lang='pug'>
tr
  td
    slot(v-if='$slots.image' name='image')
    i(v-else :class='devIconClass' :style='devIconStyle')
  td {{ name }}
  td
    slot(v-if='$slots.details' name='details')
    span(v-else) {{ details }}
</template>

<script>
export default {
  props: {
    name: {
      type: String,
      required: true,
    },
    details: {
      type: String,
      required: false,
    },
    imageSource: {
      type: String,
      required: false,
    },
    devIconStyle: {
      type: String,
      required: false,
    },
    iconIdentifier: {
      type: String,
      required: false,
    },
    plainIcon: {
      type: Boolean,
      default: true,
    },
    coloredIcon: {
      type: Boolean,
      default: true,
    },
    wordmarkedIcon: {
      type: Boolean,
      default: true,
    },
  },

  computed: {
    devIconClass() {
      const iconIdentifier = this.iconIdentifier || this.name.toLowerCase();
      let iconClass = `devicon-${iconIdentifier}`;
      if (this.plainIcon) iconClass = `${iconClass}-plain`;
      if (this.wordmarkedIcon) iconClass = `${iconClass}-wordmark`;
      if (this.coloredIcon) iconClass = `${iconClass} colored`;

      return iconClass;
    },
  },
};
</script>

<style lang='scss' scoped>
@import 'css/variables.scss';

i[class^=devicon-] {
  font-size: 65px;

  @media (max-width: 550px) {
    font-size: 45px;
  }
}

tr:not(:first-child) td {
  border-top: 1px solid $gray-lighter;
}

td {
  padding: 10px;
  height: 75px;
  vertical-align: middle;

  :deep(img) {
    width: 65px;
  }

  @media (max-width: 550px) {
    padding: 10px 4px;

    :deep(img) {
      width: 50px;
    }
  }
}

td:nth-child(2) {
  font-weight: bold;
  text-align: center;
}
</style>
