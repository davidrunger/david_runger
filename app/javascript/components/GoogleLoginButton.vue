<template lang="pug">
google-sign-in-button(:action="formAction")
</template>

<script setup lang="ts">
import { users_auth_google_oauth2_callback_path } from '@/rails_assets/routes';

import '@/custom_elements/google_sign_in_button';
import { string } from 'vue-types';

const props = defineProps({
  origin: string().isRequired,
});

const formAction = [
  `/auth/google_oauth2?`,
  `redirect_uri=${window.location.origin}${users_auth_google_oauth2_callback_path()}&`,
  `origin=${encodeURIComponent(props.origin)}`,
].join('');
</script>
