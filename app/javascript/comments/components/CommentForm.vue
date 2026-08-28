<template lang="pug">
form.my-4(@submit.prevent="handleSubmit")
  textarea.w-full.resize-y.rounded.border.border-neutral-300.p-2(
    v-model="content"
    placeholder="Write a comment..."
    rows="6"
  )
  .mt-3.flex.gap-3
    button.cursor-pointer.rounded.border-0.bg-blue-600.px-4.py-2.text-white(
      type="submit"
    ) {{ submitLabel || 'Post' }}
    template(v-if="store.currentUser && isNewComment")
      span.flex.items-center.gap-2
        | as
        |
        GravatarAndPublicName(
          :user="store.currentUser"
          :showEditLink="true"
        )
    button.cursor-pointer.rounded.border-0.bg-neutral-600.px-4.py-2.text-white(
      v-if="initialContent || parentCommentId"
      type="button"
      @click="$emit('cancel')"
    ) Cancel
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';
import { integer, string } from 'vue-types';

import GravatarAndPublicName from '@/comments/components/GravatarAndPublicName.vue';

import { useCommentsStore } from '../stores/commentsStore';

const props = defineProps({
  initialContent: string(),
  parentCommentId: integer(),
  submitLabel: string(),
});

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
