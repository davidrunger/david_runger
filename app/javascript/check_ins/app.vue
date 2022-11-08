<template lang='pug'>
h2 Your answers
Ratings(
  :needSatisfactionRatings='checkInsStore.user_ratings_of_partner'
  :editable='true'
  ratedUser='partner'
)

hr.my4

h2 Their answers
Ratings(
  v-if='checkInsStore.partner_ratings_of_user'
  :needSatisfactionRatings='checkInsStore.partner_ratings_of_user'
  :editable='false'
  ratedUser='self'
)
div(v-else) {{bootstrap.partner_ratings_hidden_reason}}
</template>

<script>
import { useCheckInsStore } from '@/check_ins/store';
import Ratings from './components/ratings.vue';

export default {
  components: {
    Ratings,
  },

  data() {
    return {
      checkInsStore: useCheckInsStore(),
    };
  },
};
</script>
