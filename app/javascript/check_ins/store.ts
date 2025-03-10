import { defineStore } from 'pinia';

import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { assert } from '@/lib/helpers';
import { http } from '@/lib/http';
import { getById } from '@/lib/store_helpers';
import {
  api_check_in_check_in_submissions_path,
  api_need_satisfaction_rating_path,
} from '@/rails_assets/routes';

import { Bootstrap, NeedSatisfactionRating } from './types';

const bootstrap = untypedBootstrap as Bootstrap;

export const useCheckInsStore = defineStore('check-ins', {
  state: () => ({
    ...bootstrap,
  }),

  actions: {
    modifyRating({
      needSatisfactionRating,
      attributes,
    }: {
      needSatisfactionRating?: NeedSatisfactionRating;
      attributes: { id?: number; score: number | null };
    }) {
      needSatisfactionRating =
        needSatisfactionRating ||
        getById(this.partner_ratings_of_user, assert(attributes.id));

      Object.assign(needSatisfactionRating, attributes);
    },

    setPartnerRatingsOfUser({
      ratings,
    }: {
      ratings: Array<NeedSatisfactionRating>;
    }) {
      this.partner_ratings_hidden_reason = null;
      this.partner_ratings_of_user = ratings;
    },

    async submitCheckIn() {
      await http.post(api_check_in_check_in_submissions_path(this.check_in.id));
    },

    updateRating({
      needSatisfactionRating,
      attributes,
    }: {
      needSatisfactionRating: NeedSatisfactionRating;
      attributes: { score: number };
    }) {
      this.modifyRating({ needSatisfactionRating, attributes });
      http.patch(api_need_satisfaction_rating_path(needSatisfactionRating.id), {
        json: { need_satisfaction_rating: attributes },
      });
    },
  },

  getters: {
    submitted(): boolean {
      return this.check_in.submitted;
    },
  },
});
