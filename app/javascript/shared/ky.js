import ky from 'ky';

let kyApi = ky; // eslint-disable-line import/no-mutable-exports

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
if (csrfMetaTag) {
  const csrfToken = csrfMetaTag.getAttribute('content');
  kyApi = ky.extend({
    hooks: {
      beforeRequest: [
        request => { request.headers.set('X-CSRF-Token', csrfToken); },
      ],
    },
  });
}

export { kyApi };
