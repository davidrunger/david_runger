import { defineStore } from 'pinia';
import { kyApi } from '@/shared/ky';

const state = () => ({
  ...window.davidrunger.bootstrap,
});

const actions = {
  modifyRating({ needSatisfactionRating, attributes }) {
    Object.assign(needSatisfactionRating, attributes);
  },

  setPartnerRatingsOfUser({ ratings }) {
    this.partner_ratings_hidden_reason = null;
    this.partner_ratings_of_user = ratings;
  },

  submitCheckIn() {
    return kyApi.
      post(
        Routes.api_check_in_check_in_submissions_path(
          this.check_in.id,
        ),
      );
  },

  updateRating({ needSatisfactionRating, attributes }) {
    this.modifyRating({ needSatisfactionRating, attributes });
    kyApi.patch(
      Routes.api_need_satisfaction_rating_path(needSatisfactionRating.id),
      { json: { need_satisfaction_rating: attributes } },
    );
  },
};

export const useCheckInsStore = defineStore('check-ins', {
  state,
  actions,
});
