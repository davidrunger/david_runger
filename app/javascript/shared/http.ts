import xior from 'xior';

import { toast } from '@/lib/toast';
import { assert } from '@/shared/helpers';

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
const csrfToken = assert(csrfMetaTag?.getAttribute('content'));

export const http = xior.create({
  headers: {
    'X-CSRF-Token': csrfToken,
  },
});

http.interceptors.response.use(
  (successfulResponse) => successfulResponse,
  (error) => {
    if (error?.response?.status === 422) {
      const { errors } = error.response.data;

      for (const error of errors) {
        toast(error, { type: 'error' });
      }
    }

    return false;
  },
);
