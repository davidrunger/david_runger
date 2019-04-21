import 'spec_helper';
import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import Logs from 'log/logs.vue';
import { logVuexStoreFactory } from 'log/store';
import * as util from 'test_utils';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Logs', function () { // eslint-disable-line func-names
  let bootstrap;
  let vuexStore;
  let wrapper;

  const userId = 1;
  const userEmail = 'davidjrunger@gmail.com';

  const heightLogName = 'Height';
  const weightLogName = 'Weight';

  beforeEach(() => {
    bootstrap = {
      current_user: {
        id: userId,
        email: userEmail,
      },
      log_input_types: [
        { public_type: 'duration', label: 'Duration' },
        { public_type: 'integer', label: 'Integer' },
        { public_type: 'text', label: 'Text' },
      ],
      logs: [
        {
          id: 1,
          log_entries: [],
          log_inputs: [{ label: 'Weight (in lbs)', public_type: 'integer' }],
          name: weightLogName,
        },
        {
          id: 2,
          log_entries: [],
          log_inputs: [{ label: 'Height (in inches)', public_type: 'integer' }],
          name: heightLogName,
        },
      ],
    };
    vuexStore = logVuexStoreFactory(bootstrap);
    wrapper = mount(
      Logs,
      {
        localVue,
        mocks: { bootstrap },
        store: vuexStore,
        stubs: {
          // Needed for some reason to render el-select/el-option in new_log_form.vue.
          // https://github.com/vuejs/vue-test-utils/issues/958#issuecomment-441421427
          transition: false,
        },
      },
    );
  });

  it('is a Vue instance', () => {
    expect(wrapper.isVueInstance()).toBeTruthy();
  });

  it("shows the current user's email", () => {
    expect(wrapper.text()).toMatch(userEmail);
  });

  it('links to each log', () => {
    [heightLogName, weightLogName].forEach(logName => {
      expect(util.findAll(wrapper, `a.js-link:text(${logName})`)).toExist();
    });
  });
});
