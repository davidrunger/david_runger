/* eslint-env mocha */

import 'spec_helper';
import { mount, createLocalVue } from 'vue-test-utils';
import { noop } from 'lodash';
import Vuex from 'vuex';
import Item from 'groceries/item.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Item', () => {
  let item;
  let store;
  let wrapper;

  beforeEach(() => {
    item = { id: 48, name: 'bananas', needed: 0 };
    store = new Vuex.Store({
      state: {},
      actions: {
        updateItem: noop,
      },
    });
    wrapper = mount(
      Item,
      {
        localVue,
        propsData: {
          item,
        },
        store,
      });
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
        const itemNameSpan = _.find(spans, span => span.text() === 'bananas');
        itemNameSpan.trigger('dblclick');
      });

      it('converts to a text input', () => {
        expect(wrapper.contains('input[type="text"]')).toBeTruthy();
      });

      describe('when I change the item name and press enter', () => {
        beforeEach(() => {
          const input = wrapper.find('input[type="text"]');
          item.name = 'organic bananas'; // user types new value; item.name updates via v-model
          input.trigger('keydown.enter');
        });

        it('removes the text input', () => {
          expect(wrapper.contains('input')).toBe(false);
        });

        it('updates the item text shown on the client', () => {
          const spans = wrapper.findAll('span').wrappers;
          const itemNameSpan = _.find(spans, span => span.text() === 'organic bananas');
          expect(itemNameSpan.exists()).toBe(true);
        });
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
