import 'spec_helper';
import { mount, createLocalVue } from '@vue/test-utils';
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
      },
    );
  });

  it('renders item.name in a span', () => {
    expect(util.findAll(wrapper, 'span:text(bananas)')).toExist();
  });
});
