<template lang="pug">
template(v-if="user?.public_name && user.gravatar_url")
  img.h-8.w-8.rounded-full(
    :src="user.gravatar_url"
    :alt="user.public_name"
    crossorigin="anonymous"
  )
|
|
template(v-if="isEditingPublicName")
  input.px-2.py-1(
    class="focus-visible:outline-none"
    type="text"
    v-model="editablePublicNameRef"
    placeholder="Public display name"
    ref="publicNameInputRef"
    v-bind="publicNameInputEventHandlers"
  )
template(v-else)
  span.font-bold {{ authorPublicNameOrFallback }}
template(v-if="showEditLink && !isEditingPublicName")
  span.text-xs
    |
    | [#[button.text-blue-600(@click="startEditingPublicName(user?.public_name || '')") Edit your name]]
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { bool, nullable, object, oneOfType } from 'vue-types';

import { useCommentsStore } from '@/comments/stores/commentsStore';
import { useCancelableInput } from '@/lib/composables/useCancelableInput';
import { type UserSerializerPublic } from '@/types';

const store = useCommentsStore();

const {
  editableRef: editablePublicNameRef,
  isEditing: isEditingPublicName,
  startEditing: startEditingPublicName,
  inputEventHandlers: publicNameInputEventHandlers,
} = useCancelableInput({
  onUpdate(newPublicName) {
    store.updateCurrentUser({ public_name: newPublicName });
  },
  refName: 'publicNameInputRef',
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
