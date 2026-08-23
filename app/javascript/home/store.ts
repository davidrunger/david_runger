import { last, pull } from 'es-toolkit';
import { defineStore } from 'pinia';

import { assert } from '@/lib/helpers';

const SECTION_ORDER = ['about', 'skills', 'projects', 'resume', 'contact'];

export const useHomeStore = defineStore('home', {
  state: () => ({
    clickedSection: null as null | string,
    homeIsVisible: true,
    menuOpen: false,
    visibleSections: [] as Array<string>,
  }),

  actions: {
    addSectionShowing(section: string) {
      if (this.visibleSections.includes(section)) return;

      this.visibleSections = [...this.visibleSections, section].sort(
        (sectionA, sectionB) =>
          SECTION_ORDER.indexOf(sectionA) - SECTION_ORDER.indexOf(sectionB),
      );
    },

    registerClickedSection(section: string) {
      this.clickedSection = section;
    },

    removeSectionShowing(section: string) {
      if (this.clickedSection === section) this.clickedSection = null;
      pull(this.visibleSections, [section]);
    },
  },

  getters: {
    activeSection(): string | null {
      if (this.clickedSection) return this.clickedSection;
      if (!this.visibleSections.length) return null;

      return assert(last(this.visibleSections));
    },
  },
});
