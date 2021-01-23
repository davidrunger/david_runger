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

const state = {
  ...window.davidrunger.bootstrap,
  ...ModalVuex.state,
  workout: null,
};

export default {
  state,
  actions,
  getters,
  mutations,
};
