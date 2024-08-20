import Toastify from 'toastify-js';

import { bootstrap } from '@/lib/bootstrap';

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

export function renderBootstrappedToasts() {
  const toastMessages = (bootstrap as { toast_messages?: Array<string> })
    .toast_messages;

  if (toastMessages) {
    for (const message of toastMessages) {
      toast(message);
    }
  }
}
