/* eslint-env mocha */

import 'spec_helper';
import { mount } from 'vue-test-utils';
import Item from 'groceries/item.vue';

describe('Item', () => {
  const item = { id: 48, name: 'bananas', needed: 0 };

  it('is a Vue instance', () => {
    const wrapper = mount(Item, { propsData: { item } });
    expect(wrapper.isVueInstance()).toBeTruthy();
  });
});
