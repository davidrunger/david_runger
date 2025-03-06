<template lang="pug">
form(
  :action="formAction"
  method="post"
)
  CsrfTokenHiddenInput
  button.google-login-button(type="submit")
    img(
      src="~img/google-login.png"
      alt="Sign in with Google"
    )
</template>

<script setup lang="ts">
import CsrfTokenHiddenInput from '@/components/CsrfTokenHiddenInput.vue';
import { users_auth_google_oauth2_callback_path } from '@/rails_assets/routes';

const props = defineProps({
  origin: {
    type: String,
    required: false,
    default: '',
  },
});

const formAction = [
  `/auth/google_oauth2?`,
  `redirect_uri=${window.location.origin}${users_auth_google_oauth2_callback_path()}&`,
  `origin=${encodeURIComponent(props.origin)}`,
].join('');
</script>

<style scoped lang="scss">
.google-login-button {
  background: none;
  color: inherit;
  border: none;
  padding: 0;
  font: inherit;
  cursor: pointer;
  outline: inherit;
}
</style>
