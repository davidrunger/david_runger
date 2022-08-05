<!-- eslint-disable max-len -->
<template lang='pug'>
h2 Your answers
Ratings(
  :needSatisfactionRatings='userRatingsOfPartner'
  :editable='true'
  ratedUser='partner'
)

hr.my4

h2 Their answers
Ratings(
  v-if='partnerRatingsOfUser'
  :needSatisfactionRatings='partnerRatingsOfUser'
  :editable='false'
  ratedUser='self'
)
div(v-else) {{bootstrap.partner_ratings_hidden_reason}}
</template>

<script>
import { cloneDeep } from 'lodash';
import Ratings from './components/ratings.vue';

export default {
  components: {
    Ratings,
  },

  data() {
    return {
      partnerRatingsOfUser: cloneDeep(this.bootstrap.partner_ratings_of_user),
      userRatingsOfPartner: cloneDeep(this.bootstrap.user_ratings_of_partner),
    };
  },
};
</script>

<style>
.el-popper {
  max-width: 50%;
}
</style>
