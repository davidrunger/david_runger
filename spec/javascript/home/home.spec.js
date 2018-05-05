import 'spec_helper';
import { createLocalVue, mount } from '@vue/test-utils';
import Home from 'home/home.vue';

describe('Home', function () { // eslint-disable-line func-names, prefer-arrow-callback
  const localVue = createLocalVue();

  let home;

  beforeEach(() => {
    home = mount(Home, { localVue });
  });

  it('is a Vue instance', () => {
    expect(home.isVueInstance()).toBeTruthy();
  });

  it('renders a basic headline', () => {
    expect(home.text()).toContain('David Runger');
    expect(home.text()).toContain('Full stack web developer');
  });
});
