import Toastify from 'toastify-js';

import 'toastify-js/src/toastify.css';

type ToastType = 'error';

const TYPE_TO_CLASS_MAP = {
  error: 'error',
};

type ToastifyOptions = {
  type?: ToastType;
};

export function toast(message: string, options?: ToastifyOptions) {
  Toastify({
    text: message,
    position: 'center',
    duration: 3000,
    className: options?.type && TYPE_TO_CLASS_MAP[options?.type],
  }).showToast();
}
