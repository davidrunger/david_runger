import { createPinia, setActivePinia } from 'pinia';

import { useHomeStore } from './store';

describe('useHomeStore', () => {
  let homeStore: ReturnType<typeof useHomeStore>;

  beforeEach(() => {
    setActivePinia(createPinia());
    homeStore = useHomeStore();
  });

  it('orders the links section after the resume section', () => {
    homeStore.addSectionShowing('resume');
    homeStore.addSectionShowing('links');

    expect(homeStore.activeSection).toBe('links');
  });

  it('keeps a clicked section active through automated observer changes', () => {
    homeStore.registerClickedSection('links');
    homeStore.removeSectionShowing('links');
    homeStore.addSectionShowing('resume');

    expect(homeStore.activeSection).toBe('links');
  });

  it('releases a clicked section after the user scrolls it out of view', () => {
    homeStore.addSectionShowing('links');
    homeStore.registerClickedSection('links');
    homeStore.registerUserScroll();
    homeStore.removeSectionShowing('links');
    homeStore.addSectionShowing('resume');

    expect(homeStore.activeSection).toBe('resume');
  });
});
