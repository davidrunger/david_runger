import { onMounted, onUnmounted } from 'vue';
import { on } from '@/lib/event_bus';

export function useSubscription(eventName, handler) {
  let unsubscriber;

  onMounted(() => {
    unsubscriber = on(eventName, handler);
  });

  onUnmounted(() => {
    unsubscriber();
  });
}
