<template lang="pug">
.comments-container
  h2 Comments

  template(v-if="store.currentUser")
    CommentForm(@submit="store.addComment")
  template(v-else)
    p
      a(
        :href="new_user_session_path(loginPathQueryParams)"
      ) Sign in / sign up
      |
      | to add a comment.

  .comments
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
import { onMounted } from 'vue';

import Comment from '@/comments/components/Comment.vue';
import CommentForm from '@/comments/components/CommentForm.vue';
import { useCommentsStore } from '@/comments/stores/commentsStore';
import { new_user_session_path } from '@/rails_assets/routes';

const store = useCommentsStore();

const loginPathQueryParams = {
  redirect_chain: `wizard:set-public-name-if-new|${window.location.toString()}`,
};

onMounted(() => {
  store.fetchInitialData();
});
</script>

<style scoped>
.comments-container {
  width: 90%;
  margin: 24px auto 0;
}

.comments {
  margin-top: 2rem;
}

.no-comments {
  text-align: center;
  color: #666;
}
</style>
