import ky, { type Hooks } from 'ky';

import { toast } from '@/lib/toasts';

const hooks: Hooks = {
  afterResponse: [
    async (_request, _options, response) => {
      if (response.status === 422) {
        const { errors } = await response.json();

        for (const error of errors) {
          toast(error, { type: 'error' });
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
  hooks,
  throwHttpErrors: false,
});

export const http = {
  async post<T>(url: string, data: object) {
    return (await kyApi.post(url, { json: data }).json()) as T;
  },
};
