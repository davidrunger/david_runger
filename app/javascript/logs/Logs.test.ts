import { render } from '@testing-library/vue';
import type { Component } from 'vue';

const { fetchAllLogEntries, isSharedLogView, selectedLog, showModal } =
  vi.hoisted(() => ({
    fetchAllLogEntries: vi.fn(),
    isSharedLogView: { __v_isRef: true, value: false },
    selectedLog: { value: { id: 1 } },
    showModal: vi.fn(),
  }));

vi.mock('pinia', () => ({
  storeToRefs: vi.fn(() => ({ isSharedLogView, selectedLog })),
}));
vi.mock('@/lib/modal/store', () => ({
  useModalStore: vi.fn(() => ({ showModal })),
}));
vi.mock('@/lib/removeQueryParams', () => ({
  removeQueryParams: vi.fn(),
}));
vi.mock('@/lib/vueToasts', () => ({
  renderBootstrappedToasts: vi.fn(),
}));
vi.mock('@/logs/store', () => ({
  useLogsStore: vi.fn(() => ({ fetchAllLogEntries })),
}));
vi.mock('./components/LogSelectorModal.vue', () => ({
  default: { template: '<div />' },
}));

describe('Logs', () => {
  let Logs: Component;

  beforeAll(async () => {
    window.davidrunger = {
      bootstrap: {
        log_selector_keyboard_shortcut: 'Ctrl+K',
      },
      env: 'test',
    };
    ({ default: Logs } = await import('./Logs.vue'));
  });

  beforeEach(() => {
    vi.clearAllMocks();
    vi.useFakeTimers();
    isSharedLogView.value = false;
    selectedLog.value = { id: 1 };
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('cleans up the keyboard listener when unmounted', () => {
    const { unmount } = render(Logs, {
      global: {
        mocks: { $route: { fullPath: '/logs/test-log' } },
        stubs: { RouterView: true },
      },
    });

    document.dispatchEvent(
      new KeyboardEvent('keydown', { ctrlKey: true, key: 'k' }),
    );
    expect(showModal).toHaveBeenCalledWith({ modalName: 'log-selector' });

    unmount();
    showModal.mockClear();

    document.dispatchEvent(
      new KeyboardEvent('keydown', { ctrlKey: true, key: 'k' }),
    );
    expect(showModal).not.toHaveBeenCalled();
  });

  it('clears the delayed log-entry fetch when unmounted', () => {
    const { unmount } = render(Logs, {
      global: {
        mocks: { $route: { fullPath: '/logs/test-log' } },
        stubs: { RouterView: true },
      },
    });

    unmount();
    vi.runAllTimers();

    expect(fetchAllLogEntries).not.toHaveBeenCalled();
  });
});
