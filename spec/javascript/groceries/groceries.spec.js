import 'spec_helper';
import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import Groceries from 'groceries/groceries.vue';
import { groceryVuexStoreFactory } from 'groceries/store';
import * as util from 'test_utils';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Groceries', function () { // eslint-disable-line func-names, prefer-arrow-callback
  let bootstrap;
  let vuexStore;
  let wrapper;

  const userId = 1;
  const userEmail = 'davidjrunger@gmail.com';

  beforeEach(() => {
    bootstrap = { stores: [], current_user: { id: userId, email: userEmail } };
    vuexStore = groceryVuexStoreFactory(bootstrap);
    wrapper = mount(Groceries, { localVue, store: vuexStore, mocks: { bootstrap } });
  });

  it("renders the user's email", () => {
    expect(wrapper.text()).toMatch(userEmail);
  });

  it('renders a link to the account settings page', () => {
    expect(util.findAll(wrapper, `a[href="/users/${userId}/edit"]:text(Account Settings)`)).
      toExist();
  });

  it('renders a link to sign out', () => {
    expect(util.findAll(wrapper, 'a.js-link:text(Sign Out)')).toExist();
  });

  it('renders the sidebar', () => {
    expect(wrapper.findAllComponents({ name: 'Sidebar' }).length).toEqual(1);
  });
});
