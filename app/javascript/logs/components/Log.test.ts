import { render } from '@testing-library/vue';
import type { Component } from 'vue';

const { createSubscription, log, unsubscribe } = vi.hoisted(() => {
  const unsubscribe = vi.fn();

  return {
    createSubscription: vi.fn(() => ({ unsubscribe })),
    log: {
      data_type: 'text',
      description: 'A test log',
      email_submission_token_last_rotated_at: null,
      id: 1,
      log_entries: [],
      log_shares: [],
      name: 'Test log',
      publicly_viewable: true,
      reminder_time_in_seconds: null,
      slug: 'test-log',
      user: { email: 'user@example.com' },
    },
    unsubscribe,
  };
});

vi.mock('pinia', () => ({
  storeToRefs: vi.fn(() => ({
    isSharedLogView: { __v_isRef: true, value: false },
  })),
}));
vi.mock('@element-plus/icons-vue', () => ({ ArrowDown: {} }));
vi.mock('@vueuse/core', () => ({ useTitle: vi.fn() }));
vi.mock('element-plus', () => {
  const component = { template: '<div><slot /></div>' };

  return {
    ElButton: component,
    ElButtonGroup: component,
    ElDropdown: component,
    ElDropdownItem: component,
    ElDropdownMenu: component,
    ElMessageBox: { confirm: vi.fn() },
    ElPopconfirm: component,
  };
});
vi.mock('@/channels/consumer', () => ({
  default: {
    subscriptions: { create: createSubscription },
  },
}));
vi.mock('@/lib/modal/store', () => ({
  useModalStore: vi.fn(() => ({ showModal: vi.fn() })),
}));
vi.mock('@/logs/store', () => ({
  useLogsStore: vi.fn(() => ({
    selectedLog: log,
  })),
}));
vi.mock('@/rails_assets/routes', () => ({
  download_log_path: vi.fn(() => '/logs/test-log.csv'),
}));
vi.mock('./EditLogRemindersModal.vue', () => ({
  default: { template: '<div />' },
}));
vi.mock('./EditLogSharingSettingsModal.vue', () => ({
  default: { template: '<div />' },
}));
vi.mock('./NewLogEntryForm.vue', () => ({
  default: { template: '<div />' },
}));
vi.mock('./data_renderers/CounterBarGraph.vue', () => ({
  default: { template: '<div />' },
}));
vi.mock('./data_renderers/DurationTimeseries.vue', () => ({
  default: { template: '<div />' },
}));
vi.mock('./data_renderers/IntegerTimeseries.vue', () => ({
  default: { template: '<div />' },
}));
vi.mock('./data_renderers/TextLog.vue', () => ({
  default: { template: '<div />' },
}));

describe('Log', () => {
  let Log: Component;

  beforeAll(async () => {
    ({ default: Log } = await import('./Log.vue'));
  });

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('unsubscribes from the log entries channel when unmounted', () => {
    const { unmount } = render(Log);

    expect(createSubscription).toHaveBeenCalledWith(
      { channel: 'LogEntriesChannel', log_id: log.id },
      expect.any(Object),
    );

    unmount();

    expect(unsubscribe).toHaveBeenCalledOnce();
  });
});
