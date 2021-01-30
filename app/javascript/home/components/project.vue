<template lang='pug'>
.mt2
  .card
    .card__body
      .project.py1.px3
        h2.h2.center.mb1
          slot(name='title')
        .center.gray.mb1
          slot(name='technologies')
        .center.mb2
          slot(name='links')

        .mb3.center
          slot(name='image')

        slot(name='overview')

        h3.h3.bold.mb1(v-if='this.$slots["tech-list"]') Tech
        slot(name='tech-list')
</template>

<style>
.card {
  border-radius: 4px;
  border: 1px solid #ebeef5;
  background-color: #fff;
  overflow: hidden;
  color: #303133;
  transition: 0.3s;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card__body {
  padding: 20px;
}
</style>
