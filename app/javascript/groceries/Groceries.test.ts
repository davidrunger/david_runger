import { render } from '@testing-library/vue';
import { createPinia, setActivePinia } from 'pinia';
import type { Component } from 'vue';

const { createSubscription } = vi.hoisted(() => ({
  createSubscription: vi.fn(),
}));

vi.mock('@/channels/consumer', () => ({
  default: {
    subscriptions: { create: createSubscription },
  },
}));
vi.mock('@/lib/vue_toasts', () => ({
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

  it('pulls store data after reconnecting', () => {
    const pinia = createPinia();
    setActivePinia(pinia);
    const groceriesStore = useGroceriesStore();
    const pullStoreData = vi
      .spyOn(groceriesStore, 'pullStoreData')
      .mockResolvedValue();
    render(Groceries, { global: { plugins: [pinia] } });

    expect(createSubscription).toHaveBeenCalledOnce();
    const callbacks = createSubscription.mock.calls[0][1] as {
      connected(args: { reconnected: boolean }): void;
    };

    callbacks.connected({ reconnected: false });
    expect(pullStoreData).not.toHaveBeenCalled();

    callbacks.connected({ reconnected: true });
    expect(pullStoreData).toHaveBeenCalledOnce();
  });
});
