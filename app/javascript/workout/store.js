import axios from 'axios';

import * as ModalVuex from '@/shared/modal_store';

const mutations = {
  ...ModalVuex.mutations,

  addCompletedWorkout(state, { completedWorkout }) {
    state.workouts = state.workouts.concat(completedWorkout);
  },

  setWorkout(state, { workout }) {
    state.workout = workout;
  },
};

const actions = {
  initializeWorkout({ commit, state }, { workout }) {
    axios.patch(
      Routes.api_user_path({ id: state.current_user.id }),
      { user: { preferences: { default_workout: workout } } },
    );

    commit('setWorkout', { workout });
  },
};

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
