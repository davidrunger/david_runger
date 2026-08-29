import { createPinia, setActivePinia } from 'pinia';

import { http } from '@/lib/http';
import { toastErrors } from '@/lib/vueToasts';

vi.mock('@/lib/http', () => ({
  http: {
    delete: vi.fn(),
    get: vi.fn(),
    patch: vi.fn(),
    post: vi.fn(),
  },
}));
vi.mock('@/lib/vueToasts', () => ({
  toastErrors: vi.fn(),
}));

describe('useLogsStore', () => {
  let useLogsStore: typeof import('./store').useLogsStore;
  let logsStore: ReturnType<typeof useLogsStore>;

  beforeAll(async () => {
    window.davidrunger = { bootstrap: {}, env: 'test' };
    ({ useLogsStore } = await import('./store'));
  });

  beforeEach(() => {
    vi.resetAllMocks();
    setActivePinia(createPinia());
    logsStore = useLogsStore();
    logsStore.logs = [];
  });

  it('clears the posting state when creating a log fails', async () => {
    const error = new Error('Network failure');
    vi.mocked(http.post).mockRejectedValueOnce(error);

    await expect(
      logsStore.createLog({
        log: {
          data_label: 'Weight',
          data_type: 'number',
          description: '',
          name: 'Weight',
        },
      }),
    ).rejects.toThrow(error);

    expect(logsStore.postingLog).toBe(false);
  });

  it('does not add or return a log when creation returns validation errors', async () => {
    vi.mocked(http.post).mockResolvedValueOnce({
      errors: ['Name has already been taken'],
    });

    const log = await logsStore.createLog({
      log: {
        data_label: 'Weight',
        data_type: 'number',
        description: '',
        name: 'Weight',
      },
    });

    expect(log).toBeUndefined();
    expect(logsStore.logs).toEqual([]);
    expect(logsStore.postingLog).toBe(false);
    expect(toastErrors).toHaveBeenCalledWith(['Name has already been taken']);
  });
});
