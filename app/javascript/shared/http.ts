import ky, { type Hooks } from 'ky';
import { identity, pickBy } from 'lodash-es';

import { toast } from '@/lib/toasts';
import { isArrayOfStrings } from '@/lib/type_predicates';

const hooks: Hooks = {
  afterResponse: [
    async (_request, _options, response) => {
      if (response.status === 422) {
        const { errors } = (await response.json()) as { errors?: unknown };

        if (isArrayOfStrings(errors)) {
          for (const error of errors) {
            toast(error, { type: 'error' });
          }
        }

        return new Response(undefined, { status: response.status });
      }
    },
  ],
};

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
const csrfToken = csrfMetaTag?.getAttribute('content');

if (csrfToken) {
  hooks['beforeRequest'] = [
    (request) => {
      request.headers.set('X-CSRF-Token', csrfToken);
    },
  ];
}

const kyApi = ky.extend({
  headers: {
    'Content-Type': 'application/json',
  },
  hooks,
  throwHttpErrors: false,
});

export const http = {
  async delete<T>(url: string) {
    return (await kyApi.delete(url).json()) as T;
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
