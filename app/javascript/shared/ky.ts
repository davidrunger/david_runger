import ky from 'ky';

import { csrfToken } from '@/lib/csrfToken';

let kyApi = ky;

const _csrfToken = csrfToken();

if (_csrfToken) {
  kyApi = ky.extend({
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

export { kyApi };
