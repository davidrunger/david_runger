import { identity, pickBy } from 'es-toolkit/compat';
import ky from 'ky';

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
        ({ request }) => {
          request.headers.set('X-CSRF-Token', _csrfToken);
        },
      ],
    },
    retry: 0,
  });
}

async function parseResponse<T>(response: Response): Promise<T> {
  if (response.status === 204) {
    return null as T;
  } else if (response.headers.get('content-length') === '0') {
    return {} as T;
  }
  return (await response.json()) as T;
}

export const http = {
  async delete<T>(url: string) {
    return parseResponse<T>(await kyApi.delete(url));
  },

  async get<T>(url: string) {
    return parseResponse<T>(await kyApi.get(url));
  },

  async patch<T>(url: string, data?: object) {
    return parseResponse<T>(
      await kyApi.patch(url, pickBy({ json: data }, identity)),
    );
  },

  async post<T>(url: string, data?: object) {
    return parseResponse<T>(
      await kyApi.post(url, pickBy({ json: data }, identity)),
    );
  },
};
