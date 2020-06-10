<template lang='pug'>
div
  header.flex.justify-between.p1
    div {{bootstrap.current_user.email}}
    .dropdown
      i.el-icon-more.dropbtn
      ul.dropdown-content.bg-black.gray
        li.p1(@click='signOut') Sign out
  .center
    LogSelector
    router-view(:key='$route.fullPath').m3
</template>

<script>
import { mapGetters, mapState } from 'vuex';
import Toastify from 'toastify-js';
import 'toastify-js/src/toastify.css';

import signOutMixin from 'lib/mixins/sign_out_mixin';
import LogSelector from './components/log_selector.vue';

export default {
  components: {
    LogSelector,
  },

  computed: {
    ...mapGetters([
      'isSharedLog',
      'selectedLog',
    ]),

    ...mapState([
      'logs',
    ]),
  },

  created() {
    if (!this.isSharedLog) {
      // If we are viewing a specific log, we want to ensure that the log entries for that log are
      // fetched first, so delay 10ms.
      // Otherwise (i.e. if viewing index), fetch all entries immediately.
      const delayBeforeFetchingAllLogs = this.selectedLog ? 10 : 0;
      setTimeout(() => {
        this.$store.dispatch('fetchAllLogEntries');
      }, delayBeforeFetchingAllLogs);
    }

    document.addEventListener('keydown', (event) => {
      if ((event.key === 'k') && (event.metaKey === true)) {
        this.$store.commit('showModal', { modalName: 'log-selector' });
      }
    });

    // display any initial toast messages
    const toastMessages = this.bootstrap.toast_messages;
    if (toastMessages) {
      toastMessages.forEach((message) => {
        Toastify({
          text: message,
          className: 'success',
          position: 'center',
          duration: 1800,
        }).showToast();
      });
    }

    // remove any query params that might be present (e.g. `new_entry` and `auth_token`)
    window.history.replaceState({}, document.title, window.location.pathname);
  },

  mixins: [signOutMixin],
};
</script>

<style lang='scss'>
:root {
  --main-bg-color: #111;
}

body {
  background: var(--main-bg-color);
  color: #e0e0e0;
}

li.log-link-container {
  // specify the height so that changing the font on hover size doesn't push other links up/down
  height: 26px;
}

a.log-link {
  color: #e0e0e0;
  font-size: 100%;
  transition: 0.2s;

  &:hover {
    font-size: 110%;
  }
}

.el-collapse-item {
  [role='tab']:focus,
  [role='button']:focus {
    outline: none;
  }
}

.el-button {
  background: #111;

  &:focus,
  &:hover {
    background: #111;
  }
}

input[type=text],
textarea.el-textarea__inner,
.el-input input.el-input__inner,
.el-input.is-disabled input.el-input__inner {
  background: #111;
}

textarea.el-textarea__inner {
  color: #eee;
  height: 7.5rem;
}

.el-input.is-disabled input.el-input__inner {
  color: gray;
}

.el-input input.el-input__inner {
  color: white;
}

.dropdown {
  position: relative;
  display: inline-block;
}

ul.dropdown-content {
  display: none;
  position: absolute;
  right: 0;
  min-width: 120px;
  box-shadow: 0 8px 16px 0 rgba(200, 200, 200, 0.2);
  text-align: right;
  z-index: 1;
}

ul.dropdown-content li {
  cursor: pointer;
}

ul.dropdown-content li:hover {
  background-color: white;
}

.dropdown:hover ul.dropdown-content {
  display: block;
}
</style>
