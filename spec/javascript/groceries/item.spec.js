/* eslint-env mocha */

import 'spec_helper';
import { mount } from 'vue-test-utils';
import Item from 'groceries/item.vue';

describe('Item', () => {
  it('is a Vue instance', () => {
    const wrapper = mount(Item);
    expect(wrapper.isVueInstance()).toBeTruthy();
  });
});
