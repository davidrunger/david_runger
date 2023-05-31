import { defineStore } from 'pinia';
import * as RoutesType from '@/rails_assets/routes';
import { kyApi } from '@/shared/ky';
import { getById } from '@/shared/store_helpers';
import { assert } from '@/shared/helpers';
import { Bootstrap, NeedSatisfactionRating } from './types';

declare const Routes: typeof RoutesType;

export const useCheckInsStore = defineStore('check-ins', {
  state: () => ({
    ...(window.davidrunger.bootstrap as Bootstrap),
  }),

  actions: {
    modifyRating(
      {
        needSatisfactionRating,
        attributes,
      }: {
        needSatisfactionRating?: NeedSatisfactionRating,
        attributes: { id?: number, score: number },
    }) {
      needSatisfactionRating =
        needSatisfactionRating ||
          getById(this.partner_ratings_of_user, assert(attributes.id));

      Object.assign(needSatisfactionRating, attributes);
    },

    setPartnerRatingsOfUser({ ratings }: { ratings: Array<NeedSatisfactionRating> }) {
      this.partner_ratings_hidden_reason = null;
      this.partner_ratings_of_user = ratings;
    },

    async submitCheckIn() {
      await kyApi.
        post(
          Routes.api_check_in_check_in_submissions_path(
            this.check_in.id,
          ),
        );
    },

    updateRating(
      {
        needSatisfactionRating,
        attributes,
      }: {
        needSatisfactionRating: NeedSatisfactionRating,
        attributes: { score: number },
    }) {
      this.modifyRating({ needSatisfactionRating, attributes });
      kyApi.patch(
        Routes.api_need_satisfaction_rating_path(needSatisfactionRating.id),
        { json: { need_satisfaction_rating: attributes } },
      );
    },
  },

  getters: {
    submitted(): boolean {
      return this.check_in.submitted;
    },
  },
});
