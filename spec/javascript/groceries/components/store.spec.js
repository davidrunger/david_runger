import 'spec_helper';
import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import Store from 'groceries/components/store.vue';
import { groceryVuexStoreFactory } from 'groceries/store';
import * as util from 'test_utils';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Store', function () { // eslint-disable-line func-names, prefer-arrow-callback
  const suite = this;

  suite.timeout(120000); // make timeout 2 minutes to allow time to play around in `debugger`

  let store;
  let wrapper;

  beforeEach(() => {
    store = {
      id: 3,
      name: 'Costco',
      items: [{ id: 23, name: 'humus', needed: 2 }],
    };
    const bootstrap = {
      current_user: { id: 2 },
      stores: [store],
    };
    wrapper = mount(
      Store,
      {
        localVue,
        propsData: {
          store,
        },
        store: groceryVuexStoreFactory(bootstrap),
      });
  });

  it('renders store.name in a span', () => {
    expect(util.findAll(wrapper, `span:text(${store.name})`)).toExist();
  });

  it('doesnt initially show a text input', () => {
    expect(wrapper.find('input[type=text]')).not.toExist();
  });

  describe('editing the store name', () => {
    describe('when I click the edit icon', () => {
      beforeEach(() => {
        wrapper.find('.el-icon-edit-outline').trigger('click');
      });

      it('shows a text input', () => {
        expect(wrapper.findAll('input[type=text]')).toExist();
      });

      it('hides the span', (done) => {
        wrapper.vm.$nextTick(() => {
          expect(util.findAll(wrapper, `span:text(${store.name})`)).not.toExist();
          done();
        });
      });
    });
  });
});
