export default {
  methods: {
    signOut() {
      this.$http.delete(this.$routes.destroy_user_session_path({ format: 'json' })).
        then(() => { window.location.assign('/login'); });
    },
  },
};
