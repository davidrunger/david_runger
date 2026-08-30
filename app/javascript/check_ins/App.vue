<template lang="pug">
h2 Your answers
Ratings(
  :needSatisfactionRatings="checkInsStore.user_ratings_of_partner"
  :editable="true"
  ratedUser="partner"
)

hr.my-8

h2 Their answers
Ratings(
  v-if="checkInsStore.partner_ratings_of_user.length"
  :needSatisfactionRatings="checkInsStore.partner_ratings_of_user"
  :editable="false"
  ratedUser="self"
)
div(v-else) {{ checkInsStore.partner_ratings_hidden_reason }}
</template>

<script setup lang="ts">
import actionCableConsumer from '@/channels/consumer';
import { bootstrap } from '@/check_ins/bootstrap';
import { useCheckInsStore } from '@/check_ins/store';
import type { NeedSatisfactionRating } from '@/check_ins/types';

import Ratings from './components/Ratings.vue';

const checkInsStore = useCheckInsStore();

interface CheckInsCableData {
  event: string;
  originating_user_id: number;
  rating?: NeedSatisfactionRating;
  ratings?: Array<NeedSatisfactionRating>;
}

actionCableConsumer.subscriptions.create(
  {
    channel: 'CheckInsChannel',
  },
  {
    connected() {
      // NOTE: This is for tests, so that we can wait until the WebSocket is connected.
      window.davidrunger.connectedToCheckInsChannel = true;
    },

    received: (data: CheckInsCableData) => {
      if (data.originating_user_id === bootstrap.current_user.id) return;

      if (data.event === 'check-in-submitted' && data.ratings) {
        checkInsStore.setPartnerRatingsOfUser({
          ratings: data.ratings,
        });
      } else if (data.event === 'need-satisfaction-rating-updated') {
        checkInsStore.modifyRating({
          attributes: data.rating as NeedSatisfactionRating,
        });
      }
    },
  },
);
</script>
