import ky from 'ky';

import { assert } from './helpers';

let kyApi = ky;  

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
if (csrfMetaTag) {
  const csrfToken = assert(csrfMetaTag.getAttribute('content'));
  kyApi = ky.extend({
    hooks: {
      beforeRequest: [
        (request) => {
          request.headers.set('X-CSRF-Token', csrfToken);
        },
      ],
    },
    retry: 0,
  });
}

export { kyApi };
