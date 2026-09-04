import { render, screen, waitFor } from '@testing-library/vue';
import { createPinia, setActivePinia } from 'pinia';
import { nextTick, type Component } from 'vue';

import { useGroceriesStore } from '@/groceries/store';
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
});
