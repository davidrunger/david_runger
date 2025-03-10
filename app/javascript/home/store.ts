import { last, pull, sortBy } from 'lodash-es';
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

      this.visibleSections = sortBy(
        [...this.visibleSections, section],
        (sectionName) => SECTION_ORDER.indexOf(sectionName),
      );
    },

    registerClickedSection(section: string) {
      this.clickedSection = section;
    },

    removeSectionShowing(section: string) {
      if (this.clickedSection === section) this.clickedSection = null;
      pull(this.visibleSections, section);
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
