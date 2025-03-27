<template lang="pug">
template(v-if="user?.public_name && user.gravatar_url")
  img.avatar(
    :src="user.gravatar_url"
    :alt="user.public_name"
    crossorigin="anonymous"
  )
|
|
span.author {{ user ? user.public_name || 'Anonymous' : '[deleted user]' }}
template(v-if="showEditLink")
  span.edit-public-name
    |
    | [#[a(:href="editNamePath") Edit your name]]
</template>

<script setup lang="ts">
import { windowLocationWithHash } from '@/lib/windowLocation';
import { edit_public_name_my_account_path } from '@/rails_assets/routes';
import { type UserSerializerPublic } from '@/types';

defineProps<{
  showEditLink: boolean;
  user: null | UserSerializerPublic;
}>();

const editNamePath = edit_public_name_my_account_path({
  redirect_chain: windowLocationWithHash('comments'),
});
</script>

<style scoped lang="scss">
.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
}

.author {
  font-weight: bold;
}

.edit-public-name {
  font-size: 0.8rem;
}
</style>
