import { onMounted, onUnmounted } from 'vue';

import { on } from '@/lib/event_bus';

export function useSubscription(eventName: string, handler: () => void) {
  let unsubscriber = () => {};

  onMounted(() => {
    unsubscriber = on(eventName, handler);
  });

  onUnmounted(() => {
    unsubscriber();
  });
}
