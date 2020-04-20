import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import { sync } from 'vuex-router-sync';
import sinon from 'sinon';

import 'spec_helper';
import Log from 'logs/components/log.vue';
import { logVuexStoreFactory } from 'logs/store';
import router from 'logs/router';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Log', function () { // eslint-disable-line func-names, prefer-arrow-callback
  let bootstrap;
  let vuexStore;
  let wrapper;

  const weightLogName = 'Weight';

  beforeEach(() => {
    bootstrap = {
      logs: [
        {
          id: 1,
          log_entries: [],
          log_shares: [],
          log_inputs: [{ label: 'Weight (in lbs)', public_type: 'integer' }],
          name: weightLogName,
        },
      ],
    };
    vuexStore = logVuexStoreFactory(bootstrap);
    sync(vuexStore, router);
    wrapper = mount(
      Log,
      {
        localVue,
        mocks: {
          bootstrap,
        },
        router,
        store: vuexStore,
      },
    );
  });

  describe('#destroyLastEntry', () => {
    let confirmMock;

    beforeEach(() => {
      confirmMock = sinon.mock(window).expects('confirm');
    });

    afterEach(() => {
      window.confirm.restore();
    });

    it('shows a confirmation message that mentions the log name', () => {
      confirmMock =
        confirmMock.withExactArgs(
          sinon.match(new RegExp(`delete the last entry from the ${weightLogName} log?`)),
        );

      wrapper.vm.destroyLastEntry();

      confirmMock.verify();
    });

    describe('when the user confirms that they want to delete the log entry', () => {
      let dispatchMock;

      beforeEach(() => {
        confirmMock = confirmMock.returns(true);
        dispatchMock =
          sinon.mock(wrapper.vm.$store).
            expects('dispatch').
            withExactArgs(
              'deleteLastLogEntry',
              { log: wrapper.vm.log },
            );
      });

      afterEach(() => {
        wrapper.vm.$store.dispatch.restore();
      });

      it('dispatches a deleteLastLogEntry action', () => {
        wrapper.vm.destroyLastEntry();

        confirmMock.verify();
        dispatchMock.verify();
      });
    });
  });
});
