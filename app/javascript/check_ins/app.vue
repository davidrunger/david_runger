<template lang="pug">
h2 Your answers
Ratings(
  :needSatisfactionRatings='checkInsStore.user_ratings_of_partner'
  :editable='true'
  ratedUser='partner'
)

hr.my-8

h2 Their answers
Ratings(
  v-if='checkInsStore.partner_ratings_of_user.length'
  :needSatisfactionRatings='checkInsStore.partner_ratings_of_user'
  :editable='false'
  ratedUser='self'
)
div(v-else) {{checkInsStore.partner_ratings_hidden_reason}}
</template>

<script lang="ts">
import actionCableConsumer from '@/channels/consumer';
import { useCheckInsStore } from '@/check_ins/store';
import { Bootstrap, NeedSatisfactionRating } from '@/check_ins/types';

import Ratings from './components/ratings.vue';

export default {
  components: {
    Ratings,
  },

  created() {
    actionCableConsumer.subscriptions.create(
      {
        channel: 'CheckInsChannel',
      },
      {
        received: (data) => {
          if (
            data.originating_user_id ===
            (this.$bootstrap as Bootstrap).current_user.id
          )
            return;

          if (data.event === 'check-in-submitted') {
            this.checkInsStore.setPartnerRatingsOfUser({
              ratings: data.ratings,
            });
          } else if (data.event === 'need-satisfaction-rating-updated') {
            this.checkInsStore.modifyRating({
              attributes: data.rating as NeedSatisfactionRating,
            });
          }
        },
      },
    );
  },

  data() {
    return {
      checkInsStore: useCheckInsStore(),
    };
  },
};
</script>
