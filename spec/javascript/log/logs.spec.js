import { mount, createLocalVue, RouterLinkStub } from '@vue/test-utils';
import Vuex from 'vuex';
import { sync } from 'vuex-router-sync';
import sinon from 'sinon';

import 'spec_helper';
import Logs from 'logs/logs.vue';
import LogsIndex from 'logs/components/logs_index.vue';
import { logVuexStoreFactory } from 'logs/store';
import router from 'logs/router';
import * as util from 'test_utils';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Logs', function () { // eslint-disable-line func-names, prefer-arrow-callback
  let bootstrap;
  let vuexStore;
  let wrapper;
  let xhr;

  const userId = 1;
  const userEmail = 'davidjrunger@gmail.com';
  const logOwner = {
    id: userId,
    email: userEmail,
  };

  const heightLogName = 'Height';
  const weightLogName = 'Weight';

  beforeEach((done) => {
    xhr = sinon.useFakeXMLHttpRequest();
    setTimeout(done, 0); // it seems to take a moment for useFakeXMLHttpRequest to kick in...

    bootstrap = {
      current_user: { ...logOwner, phone: '123-123-1234' },
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
          user: logOwner,
        },
        {
          id: 2,
          log_entries: [],
          log_inputs: [{ label: 'Height (in inches)', public_type: 'integer' }],
          name: heightLogName,
          user: logOwner,
        },
      ],
    };
    vuexStore = logVuexStoreFactory(bootstrap);
    sync(vuexStore, router);
    wrapper = mount(
      Logs,
      {
        localVue,
        mocks: {
          $route: { path: '/logs' },
          bootstrap,
        },
        router,
        store: vuexStore,
        stubs: {
          'router-link': RouterLinkStub,
          'router-view': {
            render: h => h(LogsIndex),
          },
          // Needed for some reason to render el-select/el-option in new_log_form.vue.
          // https://github.com/vuejs/vue-test-utils/issues/958#issuecomment-441421427
          transition: false,
        },
      },
    );
  });

  afterEach(() => {
    xhr.restore();
  });

  it("shows the current user's email", () => {
    expect(wrapper.text()).toMatch(userEmail);
  });

  it('links to each log', () => {
    [heightLogName, weightLogName].forEach(logName => {
      expect(util.findAll(wrapper, `a:text(${logName})`)).toExist();
    });
  });
});
