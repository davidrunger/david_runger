import xior from 'xior';

import { toast } from '@/lib/toast';

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
const csrfToken = csrfMetaTag?.getAttribute('content');

const headers =
  csrfToken ?
    {
      'X-CSRF-Token': csrfToken,
    }
  : {};

const xiorInstance = xior.create({
  headers,
});

xiorInstance.interceptors.response.use(
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

export const http = {
  async post<T>(url: string, data: object) {
    const response = await xiorInstance.post<T>(url, data);
    return response.data;
  },
}
