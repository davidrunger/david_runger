import { last, pull } from 'es-toolkit';
import { defineStore } from 'pinia';

import { assert } from '@/lib/helpers';

const SECTION_ORDER = ['about', 'skills', 'projects', 'resume', 'links'];

export const useHomeStore = defineStore('home', {
  state: () => ({
    clickedSection: null as null | string,
    homeIsVisible: true,
    menuOpen: false,
    userHasScrolled: false,
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
      this.userHasScrolled = false;
    },

    registerUserScroll() {
      this.userHasScrolled = true;

      if (
        this.clickedSection &&
        !this.visibleSections.includes(this.clickedSection)
      ) {
        this.clickedSection = null;
      }
    },

    removeSectionShowing(section: string) {
      if (this.clickedSection === section && this.userHasScrolled) {
        this.clickedSection = null;
      }
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
