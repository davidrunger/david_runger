<template lang='pug'>
div.my1(
  v-for='needSatisfactionRating in needSatisfactionRatings'
)
  strong {{needSatisfactionRating.emotional_need.name}}:
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
