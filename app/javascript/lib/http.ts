import ky from 'ky';
import { identity, pickBy } from 'lodash-es';

import { csrfToken } from '@/lib/csrfToken';

let kyApi = ky;

kyApi = kyApi.extend({
  headers: {
    'Content-Type': 'application/json',
  },
  throwHttpErrors: false,
});

const _csrfToken = csrfToken();

if (_csrfToken) {
  kyApi = kyApi.extend({
    hooks: {
      beforeRequest: [
        (request) => {
          request.headers.set('X-CSRF-Token', _csrfToken);
        },
      ],
    },
    retry: 0,
  });
}

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
