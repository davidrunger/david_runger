<template lang="pug">
.comments-container
  h2 Comments

  template(v-if="store.currentUser")
    CommentForm(@submit="store.addComment")
  template(v-else)
    p #[GoogleLoginButton.dark-mode-supported(:origin="windowLocationWithHash('comments')")] to add a comment.

  .mt-8
    template(v-if="store.comments.length")
      Comment(
        v-for="comment in store.comments"
        :key="comment.id"
        :comment="comment"
      )
    template(v-else)
      p.text-center.text-neutral-600 No comments yet.
</template>

<script setup lang="ts">
import { nextTick, onMounted } from 'vue';

import Comment from '@/comments/components/Comment.vue';
import CommentForm from '@/comments/components/CommentForm.vue';
import { useCommentsStore } from '@/comments/stores/commentsStore';
import GoogleLoginButton from '@/components/GoogleLoginButton.vue';
import { windowLocationWithHash } from '@/lib/windowLocation';

const store = useCommentsStore();

onMounted(async () => {
  await store.fetchInitialData();

  const hash = window.location.hash;
  if (hash === '#comments') {
    const element = document.getElementById(hash.substring(1));
    if (element) {
      nextTick(() => {
        element.scrollIntoView();
      });
    }
  }
});
</script>

<style scoped>
.comments-container {
  width: 90%;
  margin: 24px auto 0;

  --comments-link-color: #1b70a2;
  --comments-link-hover-color: #008d9c;
  --comments-link-active-color: #363636;
}

@media (prefers-color-scheme: dark) {
  .comments-container {
    --comments-link-color: #86cdf7;
    --comments-link-hover-color: #c7f3ff;
    --comments-link-active-color: #fff;
  }
}

.comments-container :deep(a),
.comments-container :deep(a:visited),
.comments-container :deep(button.text-blue-600) {
  color: var(--comments-link-color);
}

.comments-container :deep(a:hover),
.comments-container :deep(button.text-blue-600:hover) {
  color: var(--comments-link-hover-color);
}

.comments-container :deep(a:active),
.comments-container :deep(button.text-blue-600:active) {
  color: var(--comments-link-active-color);
}
</style>
