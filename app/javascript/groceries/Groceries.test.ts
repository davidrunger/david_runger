import { render } from '@testing-library/vue';
import { createPinia, setActivePinia } from 'pinia';
import type { Component } from 'vue';

const { createSubscription, unsubscribe } = vi.hoisted(() => {
  const unsubscribe = vi.fn();

  return {
    createSubscription: vi.fn((..._args: unknown[]) => ({ unsubscribe })),
    unsubscribe,
  };
});

vi.mock('@/channels/consumer', () => ({
  default: {
    subscriptions: { create: createSubscription },
  },
}));
vi.mock('@/lib/vueToasts', () => ({
  renderBootstrappedToasts: vi.fn(),
}));
vi.mock('./components/Sidebar.vue', () => ({
  default: { template: '<div />' },
}));
vi.mock('./components/Store.vue', () => ({
  default: { template: '<div />' },
}));

describe('Groceries', () => {
  let Groceries: Component;
  let useGroceriesStore: typeof import('./store').useGroceriesStore;

  beforeAll(async () => {
    window.davidrunger = {
      bootstrap: {
        current_user: { email: 'user@example.com', id: 1 },
        nonce: 'nonce',
        own_stores: [],
        spouse: { email: 'spouse@example.com', id: 2 },
        spouse_stores: [],
      },
      env: 'test',
    };
    ({ useGroceriesStore } = await import('./store'));
    ({ default: Groceries } = await import('./Groceries.vue'));
  });

  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('pulls store data after reconnecting', () => {
    const pinia = createPinia();
    setActivePinia(pinia);
    const groceriesStore = useGroceriesStore();
    const pullStoreData = vi
      .spyOn(groceriesStore, 'pullStoreData')
      .mockResolvedValue();
    const { unmount } = render(Groceries, { global: { plugins: [pinia] } });

    expect(createSubscription).toHaveBeenCalledOnce();
    const callbacks = createSubscription.mock.calls[0][1] as {
      connected(args: { reconnected: boolean }): void;
    };

    callbacks.connected({ reconnected: false });
    expect(pullStoreData).not.toHaveBeenCalled();

    callbacks.connected({ reconnected: true });
    expect(pullStoreData).toHaveBeenCalledOnce();

    unmount();
  });

  it('cleans up listeners and the subscription when unmounted', () => {
    const pinia = createPinia();
    setActivePinia(pinia);
    const groceriesStore = useGroceriesStore();
    groceriesStore.incrementPendingRequests();
    const { unmount } = render(Groceries, { global: { plugins: [pinia] } });

    const beforeUnloadEvent = new Event('beforeunload', { cancelable: true });
    window.dispatchEvent(beforeUnloadEvent);
    expect(beforeUnloadEvent.defaultPrevented).toBe(true);

    const touchmoveEvent = Object.assign(
      new Event('touchmove', { cancelable: true }),
      { scale: 2 },
    );
    document.dispatchEvent(touchmoveEvent);
    expect(touchmoveEvent.defaultPrevented).toBe(true);

    unmount();

    const afterBeforeUnloadEvent = new Event('beforeunload', {
      cancelable: true,
    });
    window.dispatchEvent(afterBeforeUnloadEvent);
    expect(afterBeforeUnloadEvent.defaultPrevented).toBe(false);

    const afterTouchmoveEvent = Object.assign(
      new Event('touchmove', { cancelable: true }),
      { scale: 2 },
    );
    document.dispatchEvent(afterTouchmoveEvent);
    expect(afterTouchmoveEvent.defaultPrevented).toBe(false);

    expect(unsubscribe).toHaveBeenCalledOnce();
  });
});
