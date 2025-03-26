<template lang="pug">
form.comment-form(@submit.prevent="handleSubmit")
  textarea(
    v-model="content"
    placeholder="Write a comment..."
    rows="6"
  )
  .actions
    button(type="submit") {{ submitLabel || 'Post' }}
    template(v-if="store.currentUser && isNewComment")
      span.author-identity-preview
        | as
        |
        GravatarAndPublicName(
          :user="store.currentUser"
          :showEditLink="true"
        )
    button(
      v-if="initialContent || parentCommentId"
      type="button"
      @click="$emit('cancel')"
    ) Cancel
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';

import GravatarAndPublicName from '@/comments/components/GravatarAndPublicName.vue';

import { useCommentsStore } from '../stores/commentsStore';

const props = defineProps<{
  initialContent?: string;
  parentCommentId?: number;
  submitLabel?: string;
}>();

const store = useCommentsStore();

const isNewComment = computed(() => !props.initialContent);

const emit = defineEmits<{
  (e: 'submit', content: string): void;
  (e: 'cancel'): void;
}>();

const content = ref(props.initialContent || '');

const handleSubmit = () => {
  const trimmedContent = content.value.trim();

  if (trimmedContent) {
    emit('submit', trimmedContent);
    content.value = '';
  }
};
</script>

<style scoped>
.comment-form {
  margin: 1rem 0;
}

.author-identity-preview {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  resize: vertical;
}

.actions {
  margin-top: 0.7rem;
  display: flex;
  gap: 0.7rem;
}

button {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  background: #666;
  color: white;
  cursor: pointer;
}

button[type='submit'] {
  background: #06c;
}
</style>
