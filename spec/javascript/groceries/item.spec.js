/* eslint-env mocha */

import 'spec_helper';
import { mount } from 'vue-test-utils';
import Item from 'groceries/item.vue';

describe('Item', () => {
  const item = { id: 48, name: 'bananas', needed: 0 };
  let wrapper;

  beforeEach(() => {
    wrapper = mount(Item, { propsData: { item } });
  });

  it('is a Vue instance', () => {
    expect(wrapper.isVueInstance()).toBeTruthy();
  });

  it('renders item.name in a span', () => {
    expect(
      _.some(wrapper.findAll('span').wrappers, span => span.text() === 'bananas'),
    ).toBeTruthy();
  });

  it('doesnt initially contain a text input', () => {
    expect(wrapper.contains('input[type="text"]')).toBeFalsy();
  });
});
