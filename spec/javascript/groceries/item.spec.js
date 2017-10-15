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

  describe('editing the item name', () => {
    describe('when i double click an item name', () => {
      beforeEach(() => {
        const spans = wrapper.findAll('span').wrappers;
        const itemSpan = _.find(spans, span => span.text() === 'bananas');
        itemSpan.trigger('dblclick');
      });

      it('converts to a text input', () => {
        expect(wrapper.contains('input[type="text"]')).toBeTruthy();
      });
    });

    describe('when i double click the increment button', () => {
      beforeEach(() => {
        const incrementButton = wrapper.find('.increment');
        incrementButton.trigger('dblclick');
      });

      it('doesnt convert to a text input', () => {
        expect(wrapper.contains('input[type="text"]')).toBeFalsy();
      });
    });
  });
});
