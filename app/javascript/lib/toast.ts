import Toastify from 'toastify-js';

type ToastType = 'error';

const TYPE_TO_CLASS_MAP = {
  error: 'error',
};

export function toast(message: string, options?: { type: ToastType }) {
  Toastify({
    text: message,
    position: 'center',
    duration: 3000,
    className: options?.type && TYPE_TO_CLASS_MAP[options?.type],
  }).showToast();
}
