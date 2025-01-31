import { toast } from '@/lib/toasts';

document.addEventListener('click', (event: MouseEvent) => {
  const target = event.target as HTMLElement;

  if (target.classList.contains('copy-to-clipboard')) {
    const textToCopy = target.getAttribute('data-clipboard-text');

    if (textToCopy) {
      navigator.clipboard
        .writeText(textToCopy)
        .then(() => {
          toast(`Copied '${textToCopy}' to clipboard.`);
        })
        .catch(() => {
          toast('Something went wrong.', { type: 'error' });
        });
    }
  }
});
