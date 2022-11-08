import { defineStore } from 'pinia';
import { kyApi } from '@/shared/ky';

const state = () => ({
  ...window.davidrunger.bootstrap,
});

const actions = {
  modifyRating({ needSatisfactionRating, attributes }) {
    Object.assign(needSatisfactionRating, attributes);
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
