<template lang='pug'>
div.my2(
  v-for='needSatisfactionRating in needSatisfactionRatings'
)
  .mb1
    strong {{needSatisfactionRating.emotional_need.name}}
    el-tooltip(
      placement='top-end'
      :content='needSatisfactionRating.emotional_need.description'
    )
      span.circled-text.monospace i
  div
    EmojiButton(
      v-for='ratingValue in RATINGS_RANGE'
      :needSatisfactionRating='needSatisfactionRating'
      :emojis='EMOJIS.get(ratingValue)'
      :ratingValue='ratingValue'
      @set-rating-score='(rating) => needSatisfactionRating.score = rating'
    )
button.mt1.h3(@click='updateCheckIn') Update Check-in
</template>

<script>
import { cloneDeep, range } from 'lodash';
import EmojiButton from './components/emoji_button.vue';

export default {
  components: {
    EmojiButton,
  },

  created() {
    this.RATINGS_RANGE = range(-3, 4);
    this.EMOJIS = new Map([
      [-3, ['😢']],
      [-2, ['😞']],
      [-1, ['😕']],
      [0, ['😐']],
      [1, ['🙂']],
      [2, ['😀']],
      [3, ['🥰', '😍', '🤩', '😇', '🥳']],
    ]);
  },

  data() {
    return {
      needSatisfactionRatings: cloneDeep(this.bootstrap.need_satisfaction_ratings),
    };
  },

  methods: {
    updateCheckIn() {
      const needSatisfactionPayload = {};
      this.needSatisfactionRatings.forEach(needSatisfactionRating => {
        needSatisfactionPayload[needSatisfactionRating.id] =
          { score: needSatisfactionRating.score };
      });
      this.$http.patch(
        this.$routes.api_check_in_path(this.bootstrap.check_in.id),
        { json: {
          check_in: {
            need_satisfaction_rating: needSatisfactionPayload,
          },
        } },
      ).json().
        then(() => {
          window.location.reload(); // refresh page to load spouse's answers (if available)
        });
    },
  },

  props: {},
};
</script>

<style scoped>
.el-tooltip__trigger {
  display: inline-block;
  margin-left: 5px;
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
.el-popper {
  max-width: 50%;
}
</style>
