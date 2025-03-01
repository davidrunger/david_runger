<template lang="pug">
h2 Your answers
Ratings(
  :needSatisfactionRatings="checkInsStore.user_ratings_of_partner",
  :editable="true",
  ratedUser="partner"
)

hr.my-8

h2 Their answers
Ratings(
  v-if="checkInsStore.partner_ratings_of_user.length",
  :needSatisfactionRatings="checkInsStore.partner_ratings_of_user",
  :editable="false",
  ratedUser="self"
)
div(v-else) {{ checkInsStore.partner_ratings_hidden_reason }}
</template>

<script setup lang="ts">
import actionCableConsumer from '@/channels/consumer';
import { useCheckInsStore } from '@/check_ins/store';
import type { Bootstrap, NeedSatisfactionRating } from '@/check_ins/types';
import { bootstrap } from '@/lib/bootstrap';

import Ratings from './components/Ratings.vue';

const checkInsStore = useCheckInsStore();

actionCableConsumer.subscriptions.create(
  {
    channel: 'CheckInsChannel',
  },
  {
    received: (data) => {
      if (data.originating_user_id === (bootstrap as Bootstrap).current_user.id)
        return;

      if (data.event === 'check-in-submitted') {
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
