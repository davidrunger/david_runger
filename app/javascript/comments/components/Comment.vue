<template lang="pug">
.comment.mb-2.rounded.border.border-neutral-600.p-4
  .flex.items-center.gap-2
    GravatarAndPublicName(
      :showEditLink="isAuthor"
      :user="comment.user && comment.user.id === store.currentUser?.id ? store.currentUser : comment.user"
    )
    .text-sm.text-neutral-500(:title="comment.created_at") {{ timeSinceCreation }}
    .ml-auto.flex.gap-3(v-if="isAuthor")
      button.cursor-pointer.border-0.bg-transparent.text-neutral-500(
        class="hover:text-neutral-300"
        @click="isEditing = !isEditing"
      ) {{ isEditing ? 'Cancel' : 'Edit' }}
      button.cursor-pointer.border-0.bg-transparent.text-neutral-500(
        class="hover:text-neutral-300"
        @click="handleCommentDelete(comment.id)"
      ) Delete

  template(v-if="isEditing")
    CommentForm(
      :initial-content="comment.content"
      submit-label="Update"
      @submit="handleCommentUpdate"
      @cancel="isEditing = false"
    )
  template(v-else)
    .mb-4
      .my-2(v-html="formattedAndSanitizedContent")
      button.cursor-pointer.border-0.bg-transparent.p-0.text-base.text-blue-600(
        class="hover:text-blue-300"
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
import hljs from 'highlight.js/lib/core';
import bash from 'highlight.js/lib/languages/bash';
import crystal from 'highlight.js/lib/languages/crystal';
import diff from 'highlight.js/lib/languages/diff';
import dockerfile from 'highlight.js/lib/languages/dockerfile';
import erb from 'highlight.js/lib/languages/erb';
import haml from 'highlight.js/lib/languages/haml';
import javascript from 'highlight.js/lib/languages/javascript';
import json from 'highlight.js/lib/languages/json';
import lua from 'highlight.js/lib/languages/lua';
import nginx from 'highlight.js/lib/languages/nginx';
import plaintext from 'highlight.js/lib/languages/plaintext';
import ruby from 'highlight.js/lib/languages/ruby';
import scss from 'highlight.js/lib/languages/scss';
import shell from 'highlight.js/lib/languages/shell';
import sql from 'highlight.js/lib/languages/sql';
import typescript from 'highlight.js/lib/languages/typescript';
import yaml from 'highlight.js/lib/languages/yaml';
import { DateTime } from 'luxon';
import { Marked } from 'marked';
import { markedHighlight } from 'marked-highlight';
import { computed, ref } from 'vue';

import CommentForm from '@/comments/components/CommentForm.vue';
import GravatarAndPublicName from '@/comments/components/GravatarAndPublicName.vue';
import { useCommentsStore } from '@/comments/stores/commentsStore';
import { type Comment } from '@/comments/types/comment';

import 'highlight.js/styles/github-dark.css';

import { object } from 'vue-types';

const props = defineProps({
  comment: object<Comment>().isRequired,
});

const store = useCommentsStore();
const isEditing = ref(false);
const showReplyForm = ref(false);

hljs.registerLanguage('bash', bash);
hljs.registerLanguage('crystal', crystal);
hljs.registerLanguage('diff', diff);
hljs.registerLanguage('dockerfile', dockerfile);
hljs.registerLanguage('erb', erb);
hljs.registerLanguage('haml', haml);
hljs.registerLanguage('javascript', javascript);
hljs.registerLanguage('json', json);
hljs.registerLanguage('lua', lua);
hljs.registerLanguage('nginx', nginx);
hljs.registerLanguage('plaintext', plaintext);
hljs.registerLanguage('ruby', ruby);
hljs.registerLanguage('scss', scss);
hljs.registerLanguage('shell', shell);
hljs.registerLanguage('sql', sql);
hljs.registerLanguage('typescript', typescript);
hljs.registerLanguage('yaml', yaml);

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
  (): boolean =>
    !!props.comment.user &&
    !!store.currentUser &&
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

function handleCommentDelete(commentId: number) {
  if (confirm('Delete comment?')) {
    store.deleteComment(commentId);
  }
}
</script>

<style scoped>
.comment :deep(pre) {
  padding: 0;
}
</style>
