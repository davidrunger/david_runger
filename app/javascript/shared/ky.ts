import ky from 'ky';
import { assert } from './helpers';

let kyApi = ky; // eslint-disable-line import/no-mutable-exports

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
if (csrfMetaTag) {
  const csrfToken = assert(csrfMetaTag.getAttribute('content'));
  kyApi = ky.extend({
    hooks: {
      beforeRequest: [
        request => { request.headers.set('X-CSRF-Token', csrfToken); },
      ],
    },
  });
}

export { kyApi };
