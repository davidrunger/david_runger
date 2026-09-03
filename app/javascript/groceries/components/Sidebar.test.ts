import { fireEvent, render, screen, waitFor } from '@testing-library/vue';
import { createPinia } from 'pinia';

import { useGroceriesStore } from '@/groceries/store';

import Sidebar from './Sidebar.vue';

const mediaQueryListeners = new Set<(event: MediaQueryListEvent) => void>();
const mediaQueryList = {
  matches: false,
  media: '(max-width: 767px)',
  addEventListener: vi.fn(
    (eventName: string, listener: (event: MediaQueryListEvent) => void) => {
      if (eventName === 'change') mediaQueryListeners.add(listener);
    },
  ),
  removeEventListener: vi.fn(
    (eventName: string, listener: (event: MediaQueryListEvent) => void) => {
      if (eventName === 'change') mediaQueryListeners.delete(listener);
    },
  ),
};

vi.mock('./StoreListEntry.vue', () => ({
  default: { template: '<li>Store</li>' },
}));

function setCompactViewport(matches: boolean) {
  mediaQueryList.matches = matches;

  for (const listener of mediaQueryListeners) {
    listener({ matches } as MediaQueryListEvent);
  }
}

function renderSidebar() {
  const pinia = createPinia();

  return {
    ...render(Sidebar, { global: { plugins: [pinia] } }),
    groceriesStore: useGroceriesStore(pinia),
  };
}

describe('Sidebar', () => {
  beforeAll(() => {
    document.documentElement.style.setProperty(
      '--small-screen-breakpoint',
      '767px',
    );
    vi.stubGlobal(
      'matchMedia',
      vi.fn(() => mediaQueryList as unknown as MediaQueryList),
    );
  });

  beforeEach(() => {
    mediaQueryListeners.clear();
    mediaQueryList.matches = false;
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  afterAll(() => {
    document.documentElement.style.removeProperty('--small-screen-breakpoint');
    vi.unstubAllGlobals();
  });

  it('keeps the sidebar available when the viewport is wide', () => {
    const { container } = renderSidebar();

    expect(window.matchMedia).toHaveBeenCalledWith('(max-width: 767px)');
    expect(
      container
        .querySelector('#groceries-stores-sidebar')
        ?.getAttribute('aria-hidden'),
    ).toBe('false');
    expect(
      screen
        .getByRole('button', { name: 'Show stores sidebar' })
        .getAttribute('aria-expanded'),
    ).toBe('false');
  });

  it('opens and closes the compact drawer with its toggle, backdrop, and Escape key', async () => {
    setCompactViewport(true);
    const { container } = renderSidebar();
    const sidebar = container.querySelector(
      '#groceries-stores-sidebar',
    ) as HTMLElement;
    const toggle = screen.getByRole('button', {
      name: 'Show stores sidebar',
    });

    expect(sidebar.getAttribute('aria-hidden')).toBe('true');

    toggle.focus();
    await fireEvent.click(toggle);

    expect(sidebar.getAttribute('aria-hidden')).toBe('false');
    expect(toggle.getAttribute('aria-expanded')).toBe('true');
    expect(document.activeElement).toBe(toggle);
    expect(
      screen.getByRole('button', { name: 'Close stores sidebar' }),
    ).toBeTruthy();

    await fireEvent.keyDown(window, { key: 'Escape' });

    expect(sidebar.getAttribute('aria-hidden')).toBe('true');
    expect(toggle.getAttribute('aria-expanded')).toBe('false');

    await fireEvent.click(toggle);
    await fireEvent.click(
      screen.getByRole('button', { name: 'Close stores sidebar' }),
    );

    expect(sidebar.getAttribute('aria-hidden')).toBe('true');
  });

  it('closes the compact drawer after creating a store', async () => {
    setCompactViewport(true);
    const { container, groceriesStore } = renderSidebar();
    vi.spyOn(groceriesStore, 'createStore').mockResolvedValue(true);
    const toggle = screen.getByRole('button', {
      name: 'Show stores sidebar',
    });

    await fireEvent.click(toggle);
    await fireEvent.update(
      container.querySelector('input[name="newStoreName"]') as HTMLInputElement,
      'New store',
    );
    await fireEvent.submit(
      container.querySelector('form.add-store') as HTMLFormElement,
    );

    await waitFor(() => {
      expect(
        container
          .querySelector('#groceries-stores-sidebar')
          ?.getAttribute('aria-hidden'),
      ).toBe('true');
    });
  });
});
