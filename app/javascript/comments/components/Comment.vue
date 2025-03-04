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
        a(:href="editNamePath") Edit your name
        | ]
    .time-since-creation(:title="comment.created_at") {{ timeSinceCreation }}
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
import hljs from 'highlight.js';
import { DateTime } from 'luxon';
import { Marked } from 'marked';
import { markedHighlight } from 'marked-highlight';
import { computed, ref } from 'vue';

import CommentForm from '@/comments/components/CommentForm.vue';
import { useCommentsStore } from '@/comments/stores/commentsStore';
import { type Comment } from '@/comments/types/comment';
import { edit_public_name_my_account_path } from '@/rails_assets/routes';

import 'highlight.js/styles/github-dark.css';

const props = defineProps<{
  comment: Comment;
}>();

const store = useCommentsStore();
const isEditing = ref(false);
const showReplyForm = ref(false);

const editNamePath = edit_public_name_my_account_path({
  redirect_chain: window.location.toString(),
});

const marked = new Marked(
  markedHighlight({
    emptyLangClass: 'hljs',
    langPrefix: 'hljs language-',
    highlight(code, lang, info) {
      const language = hljs.getLanguage(lang) ? lang : 'plaintext';
      return hljs.highlight(code, { language }).value;
    },
  }),
);

const formattedAndSanitizedContent = computed(() => {
  const rawHtml = marked.parse(props.comment.content || '', { async: false });
  return DOMPurify.sanitize(rawHtml);
});
const timeSinceCreation = computed(() => {
  const createdAt = DateTime.fromISO(props.comment.created_at);
  return createdAt.toRelative({ base: DateTime.now() });
});

const isAuthor = computed(
  () =>
    props.comment.user &&
    store.currentUser &&
    props.comment.user.id === store.currentUser.id,
);

function handleCommentUpdate(content: string) {
  store.updateComment(props.comment.id, content);
  isEditing.value = false;
}

function handleReplyCreate(content: string) {
  store.addComment(content, props.comment.id);
  showReplyForm.value = false;
}
</script>

<style scoped>
.comment :deep(pre) {
  padding: 0;
}

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

.time-since-creation {
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
