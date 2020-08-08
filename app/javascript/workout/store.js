import Vuex from 'vuex';

import * as ModalVuex from 'shared/modal_store';

const mutations = {
  ...ModalVuex.mutations,

  addCompletedWorkout(state, { completedWorkout }) {
    state.workouts = state.workouts.concat(completedWorkout);
  },

  setWorkout(state, { workout }) {
    state.workout = workout;
  },
};

const actions = {};

const getters = {
  ...ModalVuex.getters,
};

function initialState(bootstrap) {
  return {
    ...bootstrap,
    ...ModalVuex.state,
    workout: null,
  };
}

// eslint-disable-next-line import/prefer-default-export
export function workoutVuexStoreFactory(bootstrap) {
  return new Vuex.Store({
    state: initialState(bootstrap),
    actions,
    getters,
    mutations,
  });
}

export default workoutVuexStoreFactory(window.davidrunger.bootstrap);
