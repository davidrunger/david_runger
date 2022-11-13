<!-- eslint-disable max-len -->
<template lang='pug'>
div.my2(
  v-for='needSatisfactionRating in needSatisfactionRatings'
)
  .mb1
    strong {{needSatisfactionRating.emotional_need.name}}
    el-popover(
      placement='top-end'
      trigger='click'
      :content='needSatisfactionRating.emotional_need.description'
    )
      template(#reference)
        span.circled-text.monospace.js-link i
    a.ml1(:href='graphLink(needSatisfactionRating)') graph
  div
    EmojiButton(
      v-for='ratingValue in RATINGS_RANGE'
      :needSatisfactionRating='needSatisfactionRating'
      :ratingValue='ratingValue'
      :editable='editable'
    )
button.mt1.h3(v-if='editable && !submitted' @click='submitCheckIn') Submit Check-in
</template>

<script>
import { range } from 'lodash-es';
import { mapState } from 'pinia';
import { useCheckInsStore } from '@/check_ins/store';
import EmojiButton from './emoji_button.vue';

export default {
  components: {
    EmojiButton,
  },

  computed: {
    ...mapState(useCheckInsStore, [
      'submitted',
    ]),
  },

  created() {
    this.RATINGS_RANGE = range(-3, 4);
  },

  data() {
    return {
      checkInsStore: useCheckInsStore(),
    };
  },

  methods: {
    graphLink(needSatisfactionRating) {
      return this.$routes.
        history_emotional_need_path(
          needSatisfactionRating.emotional_need.id,
          { rated_user: this.ratedUser },
        );
    },

    async submitCheckIn() {
      await this.checkInsStore.submitCheckIn();
      // refresh page to load spouse's answers (if available)
      window.location.reload();
    },
  },

  props: {
    editable: {
      type: Boolean,
      required: true,
    },
    needSatisfactionRatings: {
      type: Array,
      required: true,
    },
    ratedUser: {
      type: String,
      required: true,
    },
  },
};
</script>

<style scoped>
.el-tooltip__trigger {
  display: inline-block;
  margin-left: 3px;
}

span.circled-text {
  border: 1px solid black;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  text-align: center;
  font-weight: bold;
}
</style>

<style>
.el-popover.el-popper {
  max-width: 50%;
  word-break: initial !important;
  text-align: initial !important;
}
</style>
