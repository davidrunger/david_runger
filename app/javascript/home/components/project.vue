<template lang='pug'>
.project-container.mt2
  .card
    .card__body
      .project.p1
        h2.h2.center.mt0.mb1
          slot(name='title')
        .center.gray.mb1
          slot(name='technologies')
        .center.mb2(v-if='this.$slots["links"]')
          slot(name='links')
        .mb3.center(v-if='this.$slots["image"]')
          slot(name='image')

        slot(name='overview')

        h3.h3.bold.mb1(v-if='this.$slots["tech-list"] && this.$slots["overview"]') Tech
        slot(name='tech-list')
</template>

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
</style>
