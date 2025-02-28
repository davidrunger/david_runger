<template lang="pug">
.comment
  .comment-header
    img.avatar(
      v-if="comment.user"
      :src="comment.user.gravatar_url"
      :alt="comment.user.public_name"
      crossorigin="anonymous"
    )
    .author {{ comment.user?.public_name || '[unknown user]' }}
    template(v-if="isAuthor")
      .edit-public-name
        | [
        a(:href="editYourNamePath") Edit your name
        | ]
    .date(:title="comment.created_at") {{ formattedDate }}
    .actions(v-if="isAuthor")
      button(@click="isEditing = !isEditing") {{ isEditing ? 'Cancel' : 'Edit' }}
      button(@click="store.deleteComment(comment.id)") Delete

  template(v-if="isEditing")
    CommentForm(
      :initial-content="comment.content"
      submit-label="Update"
      @submit="handleCommentUpdate"
      @cancel="isEditing = false"
    )

  template(v-else)
    .content-and-reply-button
      .content(v-html="formattedAndSanitizedContent")
      button.reply-button(
        v-if="!showReplyForm"
        @click="showReplyForm = true"
      ) Reply

    CommentForm(
      v-if="showReplyForm"
      :parent-comment-id="comment.id"
      submit-label="Reply"
      @submit="handleReplyCreate"
      @cancel="showReplyForm = false"
    )

  template(v-if="comment.replies.length")
    Comment(
      v-for="reply in comment.replies"
      :key="reply.id"
      :comment="reply"
    )
</template>

<script setup lang="ts">
import DOMPurify from 'dompurify';
import { DateTime } from 'luxon';
import { marked } from 'marked';
import { computed, ref } from 'vue';

import CommentForm from '@/comments/components/CommentForm.vue';
import { useCommentsStore } from '@/comments/stores/commentsStore';
import { type Comment } from '@/comments/types/comment';
import { edit_public_name_my_account_path } from '@/rails_assets/routes';

const props = defineProps<{
  comment: Comment;
}>();

const store = useCommentsStore();
const isEditing = ref(false);
const showReplyForm = ref(false);

const editYourNamePath = edit_public_name_my_account_path({
  redirect_chain: window.location.toString(),
});

const formattedAndSanitizedContent = computed(() => {
  const rawHtml = marked(props.comment.content || '', { async: false });
  return DOMPurify.sanitize(rawHtml);
});
const formattedDate = computed(() => {
  const createdAt = DateTime.fromISO(props.comment.created_at);
  return createdAt.toRelative({ base: DateTime.now() });
});

const isAuthor = computed(
  () => props.comment.user && props.comment.user.id === store.currentUser?.id,
);

function handleReplyCreate(content: string) {
  store.addComment(content, props.comment.id);
  showReplyForm.value = false;
}

function handleCommentUpdate(content: string) {
  store.updateComment(props.comment.id, content);
  isEditing.value = false;
}
</script>

<style scoped>
.content-and-reply-button {
  margin-bottom: 1rem;
}

.comment {
  margin-bottom: 0.5rem;
  padding: 1rem;
  border: 1px solid #666;
  border-radius: 4px;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

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

.date {
  color: #777;
  font-size: 0.9rem;
}

.content {
  margin: 0.5rem 0;
}

.reply-button {
  font-size: 1rem;
  background: none;
  border: none;
  color: var(--link-color);
  cursor: pointer;
  padding: 0;

  &:hover {
    color: var(--link-hover-color);
  }
}

.actions {
  display: flex;
  margin-left: auto;
  gap: 0.8rem;
}

.actions button {
  background: none;
  border: none;
  color: #777;
  cursor: pointer;

  &:hover {
    color: #c7c7c7;
  }
}
</style>
