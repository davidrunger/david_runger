import Toastify from 'toastify-js';

import { bootstrap } from '@/lib/bootstrap';

type ToastType = 'error';

const TYPE_TO_CLASS_MAP = {
  error: 'error',
};

export function toast(
  message: string,
  options?: { html?: boolean; type?: ToastType },
) {
  Toastify({
    text: message,
    position: 'center',
    duration: 3000,
    className: options?.type && TYPE_TO_CLASS_MAP[options?.type],
    escapeMarkup: !options?.html,
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
