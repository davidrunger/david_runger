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
      p.no-comments No comments yet.
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
}

.no-comments {
  text-align: center;
  color: #666;
}
</style>
