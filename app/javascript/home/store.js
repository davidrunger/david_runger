import { defineStore } from 'pinia';
import { last, pull, sortBy } from 'lodash-es';

const SECTION_ORDER = ['about', 'skills', 'projects', 'resume', 'contact'];

const state = () => ({
  clickedSection: null,
  visibleSections: [],
});

const actions = {
  addSectionShowing(section) {
    if (this.visibleSections.includes(section)) return;

    this.visibleSections =
      sortBy(
        [...this.visibleSections, section],
        sectionName => SECTION_ORDER.indexOf(sectionName),
      );
  },

  registerClickedSection(section) {
    this.clickedSection = section;
  },

  removeSectionShowing(section) {
    if (this.clickedSection === section) this.clickedSection = null;
    pull(this.visibleSections, section);
  },
};

const getters = {
  activeSection() {
    if (this.clickedSection) return this.clickedSection;
    if (!this.visibleSections.length) return null;

    return last(this.visibleSections);
  },
};

export const useHomeStore = defineStore('home', {
  state,
  actions,
  getters,
});
