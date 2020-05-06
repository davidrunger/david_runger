import 'spec_helper';
import { mount, createLocalVue } from '@vue/test-utils';
import sinon from 'sinon';
import Vuex from 'vuex';
import Item from 'groceries/components/item.vue';
import { groceryVuexStoreFactory } from 'groceries/store';
import * as util from 'test_utils';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Item', function () { // eslint-disable-line func-names, prefer-arrow-callback
  const suite = this;

  suite.timeout(120000); // make timeout 2 minutes to allow time to play around in `debugger`

  let item;
  let wrapper;

  beforeEach(() => {
    item = { id: 48, name: 'bananas', needed: 0 };
    const bootstrap = {
      stores: [
        {
          id: 1,
          name: 'Costco',
          items: [item],
        },
      ],
    };
    wrapper = mount(
      Item,
      {
        localVue,
        propsData: {
          item,
        },
        store: groceryVuexStoreFactory(bootstrap),
      });
  });

  it('renders item.name in a span', () => {
    expect(util.findAll(wrapper, 'span:text(bananas)')).toExist();
  });

  it('doesnt initially show a text input', () => {
    expect(wrapper.find('input[type=text]').attributes().style).toMatch(/display: none/);
  });

  describe('editing the item name', () => {
    describe('when i double click an item name', () => {
      beforeEach(() => {
        const spans = wrapper.findAll('span').wrappers;
        const itemNameSpan = _.find(spans, span => span.text() === 'bananas');
        itemNameSpan.trigger('dblclick');
      });

      it('converts to a text input', () => {
        expect(wrapper.find('input[type="text"]').exists()).toBeTruthy();
      });

      describe('when I change the item name and press enter', () => {
        let xhr;
        let requests = [];

        beforeEach((done) => {
          xhr = sinon.useFakeXMLHttpRequest();
          requests = [];
          xhr.onCreate = request => {
            requests.push(request);
          };

          const input = wrapper.find('input[type="text"]');
          item.name = 'organic bananas'; // user types new value; item.name updates via v-model
          input.trigger('keydown.enter');

          // wait a tick for AJAX requests to register
          setTimeout(done, 0);
        });

        afterEach(() => {
          xhr.restore();
        });

        it('hides the text input', () => {
          expect(wrapper.find('input[type=text]').attributes().style).toMatch(/display: none/);
        });

        it('updates the item text shown on the client', () => {
          const spans = wrapper.findAll('span').wrappers;
          const itemNameSpan = _.find(spans, span => span.text() === 'organic bananas');
          expect(itemNameSpan.exists()).toBe(true);
        });

        it('makes a PATCH request to update the item name', () => {
          expect(requests.length).toEqual(1);
          const request = requests[0];
          expect(request.url).toEqual('/api/items/48');
          expect(request.method).toEqual('PATCH');
          expect(JSON.parse(request.requestBody)).toEqual({ item: { name: 'organic bananas' } });
        });
      });
    });

    describe('when i double click the increment button', () => {
      beforeEach(() => {
        const incrementButton = wrapper.find('.increment');
        incrementButton.trigger('dblclick');
      });

      it('doesnt convert to a text input', () => {
        expect(wrapper.find('input[type=text]').attributes().style).toMatch(/display: none/);
      });
    });
  });

  describe('decrementing the needed count of an item', () => {
    let xhr;
    let requests;
    const debounceTimeout = 500; // ms

    beforeEach(() => {
      xhr = sinon.useFakeXMLHttpRequest();
      requests = [];
      xhr.onCreate = (request) => {
        requests.push(request);
      };
    });

    afterEach(() => {
      xhr.restore();
    });

    describe('when the count of items needed is already 0', () => {
      beforeEach(() => {
        expect(item.needed).toEqual(0);
        expect(wrapper.text()).toMatch(RegExp(`${item.name}\\s\\(0\\)`));
      });

      describe('when I click the decrement button', () => {
        beforeEach((done) => {
          const decrementButton = wrapper.find('.decrement');
          decrementButton.trigger('click');
          setTimeout(done, debounceTimeout);
        });

        it('does not decrement the item count to a negative number (it remains 0)', () => {
          expect(wrapper.text()).toMatch(RegExp(`${item.name}\\s\\(0\\)`));
        });

        it('does not make an HTTP request', () => {
          expect(requests.length).toEqual(0);
        });
      });
    });

    describe('when the count of items needed is positive', () => {
      beforeEach((done) => {
        item.needed = 22;
        wrapper.vm.$nextTick(() => {
          expect(wrapper.text()).toMatch(RegExp(`${item.name}\\s\\(22\\)`));
          done();
        });
      });

      describe('when I click the decrement button', () => {
        beforeEach((done) => {
          const decrementButton = wrapper.find('.decrement');
          decrementButton.trigger('click');
          setTimeout(done, debounceTimeout);
        });

        it('decrements the item count by 1', () => {
          expect(wrapper.text()).toMatch(RegExp(`${item.name}\\s\\(21\\)`));
        });

        it('makes an HTTP request', () => {
          expect(requests.length).toEqual(1);
        });
      });
    });
  });
});
