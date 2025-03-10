import { identity, pickBy } from 'lodash-es';

import { kyApi as generalKyApi } from '@/lib/ky';

const kyApi = generalKyApi.extend({
  headers: {
    'Content-Type': 'application/json',
  },
  throwHttpErrors: false,
});

export const http = {
  async delete<T>(url: string) {
    return (await kyApi.delete(url).json()) as T;
  },

  async get<T>(url: string) {
    return (await kyApi.get(url).json()) as T;
  },

  async patch<T>(url: string, data?: object) {
    return (await kyApi
      .patch(url, pickBy({ json: data }, identity))
      .json()) as T;
  },

  async post<T>(url: string, data?: object) {
    return (
      (await kyApi
        // NOTE: Only include payload if one is provided.
        .post(url, pickBy({ json: data }, identity))
        .json()) as T
    );
  },
};
