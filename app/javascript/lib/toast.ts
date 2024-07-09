import Toastify from 'toastify-js';

export function toast(message: string) {
  Toastify({
    text: message,
    position: 'center',
    duration: 3000,
  }).showToast();
}
