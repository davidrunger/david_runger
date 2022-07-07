<template lang='pug'>
div.my1(
  v-for='needSatisfactionRating in needSatisfactionRatings'
)
  strong {{needSatisfactionRating.emotional_need.name}}:
  div
    button.need_satisfaction_rating(
      v-for='ratingValue in RATINGS_RANGE'
      :class='{selected: needSatisfactionRating.score === ratingValue}'
      @click='needSatisfactionRating.score = ratingValue'
    ) {{ratingValue}}
button.mt1.h3(@click='updateCheckIn') Update Check-in
</template>

<script>
import { cloneDeep, range } from 'lodash';

export default {
  created() {
    this.RATINGS_RANGE = range(-3, 4);
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

<style lang='scss'>
button.need_satisfaction_rating {
  width: 30px;
  margin: 0 3px;

  &.selected {
    background-color: blue;
  }
}
</style>
