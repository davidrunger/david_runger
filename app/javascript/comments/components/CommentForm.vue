<template lang="pug">
form.comment-form(@submit.prevent="handleSubmit")
  textarea(v-model="content" placeholder="Write a comment..." rows="6")
  .actions
    button(type="submit") {{ submitLabel || 'Post' }}
    button(
      v-if="initialContent || parentCommentId"
      type="button"
      @click="$emit('cancel')"
    ) Cancel
</template>

<script setup lang="ts">
import { ref } from 'vue';

import type { Comment } from '@/comments/types/comment';

const props = defineProps<{
  comment?: Comment;
  initialContent?: string;
  parentCommentId?: number;
  submitLabel?: string;
}>();

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
