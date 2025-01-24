import { type Hooks } from 'ky';
import { identity, pickBy } from 'lodash-es';

import { toast } from '@/lib/toasts';
import { isArrayOfStrings } from '@/lib/type_predicates';
import { kyApi as generalKyApi } from '@/shared/ky';

const hooks: Hooks = {
  afterResponse: [
    async (_request, _options, response) => {
      if (response.status === 422) {
        // eslint-disable-next-line @typescript-eslint/no-unnecessary-type-assertion
        const { errors } = await response.json() as { errors?: unknown };

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

const kyApi = generalKyApi.extend({
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
