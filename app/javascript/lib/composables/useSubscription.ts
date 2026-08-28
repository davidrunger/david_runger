import { onMounted, onUnmounted } from 'vue';

import { on } from '@/lib/eventBus';

export function useSubscription(eventName: string, handler: () => void) {
  let unsubscriber = () => {};

  onMounted(() => {
    unsubscriber = on(eventName, handler);
  });

  onUnmounted(() => {
    unsubscriber();
  });
}
