import { render, screen, waitFor } from '@testing-library/vue';
import { createPinia, setActivePinia } from 'pinia';
import { nextTick, type Component } from 'vue';

import { useGroceriesStore } from '@/groceries/store';
import type { Item } from '@/groceries/types';
import { useModalStore } from '@/lib/modal/store';
import type { Store } from '@/types';

import OrganizeItemsModal from './OrganizeItemsModal.vue';

vi.mock('@/components/Modal.vue', () => ({
  default: { template: '<div class="modal-container"><slot /></div>' },
}));

const store: Store = {
  id: 1,
  item_section_assignments: [],
  items: [],
  name: 'Costco',
  notes: null,
  own_store: true,
  private: false,
  section_configuration: null,
  viewed_at: null,
};

const item: Item = {
  id: 1,
  name: 'Bananas',
  needed: 1,
  store_ids: [store.id],
};

describe('OrganizeItemsModal', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
  });

  it('shows a loading state until layouts determine the initial form', async () => {
    const groceriesStore = useGroceriesStore();
    const modalStore = useModalStore();
    const consoleWarn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    let resolveLayouts!: () => void;
    const layoutsLoaded = new Promise<void>((resolve) => {
      resolveLayouts = resolve;
    });
    vi.spyOn(groceriesStore, 'pullStoreSectionSchemes').mockImplementation(
      async () => {
        await layoutsLoaded;
        groceriesStore.storeSectionSchemes = [
          { id: 1, name: 'Costco', store_sections: [] },
        ];
      },
    );

    try {
      render(OrganizeItemsModal as Component, {
        props: { items: [], stores: [store] },
      });
      modalStore.showModal({ modalName: 'organize-grocery-items' });
      await nextTick();

      expect(screen.getByText('Loading store section layouts...')).toBeTruthy();
      expect(screen.queryByText('Set up store sections')).toBeNull();

      resolveLayouts();

      await waitFor(() => {
        expect(screen.getByText('Set up store sections')).toBeTruthy();
      });

      expect(consoleWarn).not.toHaveBeenCalled();
    } finally {
      consoleWarn.mockRestore();
    }
  });

  it('highlights items without a selected section', async () => {
    const groceriesStore = useGroceriesStore();
    const modalStore = useModalStore();
    const configuredStore = {
      ...store,
      section_configuration: {
        sectioning_enabled: true,
        store_section_scheme: {
          id: 1,
          name: 'Costco layout',
          store_sections: [{ id: 1, name: 'Produce' }],
        },
      },
    };
    vi.spyOn(groceriesStore, 'pullStoreSectionSchemes').mockImplementation(
      () => {
        groceriesStore.storeSectionSchemes = [];
        return Promise.resolve();
      },
    );

    render(OrganizeItemsModal as Component, {
      props: { items: [item], stores: [configuredStore] },
    });
    modalStore.showModal({ modalName: 'organize-grocery-items' });

    const organizeItem = await waitFor(() => {
      const element = screen.getByText(item.name).closest('.organize-item');
      if (!element) throw new Error('Expected an organize item card.');

      return element;
    });

    expect(organizeItem.classList.contains('organize-item--unclassified')).toBe(
      true,
    );
  });
});
