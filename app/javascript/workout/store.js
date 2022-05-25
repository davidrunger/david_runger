import axios from 'axios';

import {
  getters as modalGetters,
  mutations as modalMutations,
  state as modalState,
} from '@/shared/modal_store';

const mutations = {
  ...modalMutations,

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
  ...modalGetters,
};

const state = {
  ...window.davidrunger.bootstrap,
  ...modalState,
  workout: null,
};

export default {
  state,
  actions,
  getters,
  mutations,
};
