<template lang="pug">
template(v-if="user?.public_name && user.gravatar_url")
  img.avatar(
    :src="user.gravatar_url"
    :alt="user.public_name"
    crossorigin="anonymous"
  )
|
|
template(v-if="isEditingPublicName")
  input.public-name-input.py-1.px-2(
    type="text"
    v-model="editablePublicNameRef"
    placeholder="Public display name"
    ref="publicNameInputRef"
    v-bind="publicNameInputEventHandlers"
  )
template(v-else)
  span.author {{ authorPublicNameOrFallback }}
template(v-if="showEditLink && !isEditingPublicName")
  span.edit-public-name
    |
    | [#[button.btn-link(@click="startEditingPublicName(user?.public_name || '')") Edit your name]]
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { bool, nullable, object, oneOfType } from 'vue-types';

import { useCommentsStore } from '@/comments/stores/commentsStore';
import { useCancellableInput } from '@/lib/composables/useCancellableInput';
import { type UserSerializerPublic } from '@/types';

const store = useCommentsStore();

const {
  editableRef: editablePublicNameRef,
  isEditing: isEditingPublicName,
  startEditing: startEditingPublicName,
  inputRef: publicNameInputRef,
  inputEventHandlers: publicNameInputEventHandlers,
} = useCancellableInput({
  onUpdate(newPublicName) {
    store.updateCurrentUser({ public_name: newPublicName });
  },
});

const props = defineProps({
  showEditLink: bool(),
  user: oneOfType<null | UserSerializerPublic>([nullable(), object()]),
});

const authorPublicNameOrFallback = computed((): string => {
  const user = props.user;

  return user ? user.public_name || `User ${user.id}` : '[deleted user]';
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

.btn-link {
  color: var(--link-color);
}

.edit-public-name {
  font-size: 0.8rem;
}

input.public-name-input {
  &:focus-visible {
    outline: none;
  }
}
</style>
