import 'spec_helper';
import { mount, createLocalVue } from '@vue/test-utils';
import sinon from 'sinon';
import Vuex from 'vuex';
import Sidebar from 'groceries/components/sidebar.vue';
import { groceryVuexStoreFactory } from 'groceries/store';
import * as util from 'test_utils';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Sidebar', function () { // eslint-disable-line func-names
  const suite = this;
  suite.timeout(120000); // make timeout 2 minutes to allow time to play around in `debugger`

  let item;
  let groceryStore;
  let bootstrap;
  let vuexStore;
  let wrapper;

  beforeEach(() => {
    item = { id: 48, name: 'bananas', needed: 0 };
    groceryStore = { id: 23, name: 'Costco', items: [item] };
    bootstrap = {
      stores: [groceryStore],
      current_user: { id: 1, email: 'davidjrunger@gmail.com' },
    };
    vuexStore = groceryVuexStoreFactory(bootstrap);
    wrapper = mount(Sidebar, { localVue, store: vuexStore, mocks: { bootstrap } });
  });

  it('renders the store name', () => {
    expect(util.findAll(wrapper, 'a:text(Costco)')).toExist();
  });

  describe("when I click a store's delete button", () => {
    let xhr;
    let requests = [];

    beforeEach((done) => {
      xhr = sinon.useFakeXMLHttpRequest();
      requests = [];
      xhr.onCreate = request => {
        requests.push(request);
      };

      util.findFirst(wrapper, 'a:text(×)').trigger('click');
      setTimeout(done, 0); // wait a tick for AJAX requests to register
    });

    afterEach(() => {
      xhr.restore();
    });

    it('makes a DELETE request to delete the store', () => {
      expect(requests.length).toEqual(1);
      const request = requests[0];
      expect(request.url).toEqual('/api/stores/23');
      expect(request.method).toEqual('DELETE');
    });

    it('removes the store from the list', () => {
      expect(wrapper.html()).not.toContain(groceryStore.name);
    });
  });
});
