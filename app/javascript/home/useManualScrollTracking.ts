import { onMounted, onUnmounted } from 'vue';

import { useHomeStore } from './store';

const MANUAL_SCROLL_KEYS = new Set([
  ' ',
  'ArrowDown',
  'ArrowLeft',
  'ArrowRight',
  'ArrowUp',
  'End',
  'Home',
  'PageDown',
  'PageUp',
]);

export function useManualScrollTracking() {
  const homeStore = useHomeStore();

  const registerUserScroll = () => homeStore.registerUserScroll();
  const registerKeyboardScroll = (event: KeyboardEvent) => {
    if (MANUAL_SCROLL_KEYS.has(event.key)) registerUserScroll();
  };

  onMounted(() => {
    window.addEventListener('pointerdown', registerUserScroll, {
      passive: true,
    });
    window.addEventListener('touchmove', registerUserScroll, {
      passive: true,
    });
    window.addEventListener('wheel', registerUserScroll, { passive: true });
    window.addEventListener('keydown', registerKeyboardScroll);
  });

  onUnmounted(() => {
    window.removeEventListener('pointerdown', registerUserScroll);
    window.removeEventListener('touchmove', registerUserScroll);
    window.removeEventListener('wheel', registerUserScroll);
    window.removeEventListener('keydown', registerKeyboardScroll);
  });
}
