<template lang="pug">
.my-8(
  v-for="needSatisfactionRating in needSatisfactionRatings"
  :key="needSatisfactionRating.id"
)
  .mb-2
    strong {{ needSatisfactionRating.emotional_need.name }}
    ElPopover(
      placement="top-end"
      trigger="click"
    )
      template(#reference)
        span.circled-text.monospace.js-link i
      div(v-if="needSatisfactionRating.emotional_need.description")
        | {{ needSatisfactionRating.emotional_need.description }}
      div(v-else)
        | No description. You can add one #[a(:href="edit_emotional_need_path(needSatisfactionRating.emotional_need.id)") here].
    a.ml-2(:href="graphLink(needSatisfactionRating)") graph
  div
    EmojiButton(
      v-for="ratingValue in RATINGS_RANGE"
      :key="ratingValue"
      :needSatisfactionRating="needSatisfactionRating"
      :ratingValue="ratingValue"
      :editable="editable"
    )

button.btn-primary.mt-2.h3(
  v-if="editable && !submitted"
  @click="submitCheckIn"
) Submit Check-in
</template>

<script setup lang="ts">
import { ElPopover } from 'element-plus';
import { range } from 'lodash-es';
import { storeToRefs } from 'pinia';
import type { PropType } from 'vue';

import { useCheckInsStore } from '@/check_ins/store';
import type { NeedSatisfactionRating, Rating } from '@/check_ins/types';
import {
  edit_emotional_need_path,
  history_emotional_need_path,
} from '@/rails_assets/routes';

import EmojiButton from './EmojiButton.vue';

const props = defineProps({
  editable: {
    type: Boolean,
    required: true,
  },
  needSatisfactionRatings: {
    type: Array as PropType<Array<NeedSatisfactionRating>>,
    required: true,
  },
  ratedUser: {
    type: String,
    required: true,
  },
});

const checkInsStore = useCheckInsStore();
const RATINGS_RANGE = range(-3, 4) as Array<Rating>;

const { submitted } = storeToRefs(checkInsStore);

function graphLink(needSatisfactionRating: NeedSatisfactionRating) {
  return history_emotional_need_path(needSatisfactionRating.emotional_need.id, {
    rated_user: props.ratedUser,
  });
}

async function submitCheckIn() {
  await checkInsStore.submitCheckIn();
  // refresh page to load spouse's answers (if available)
  window.location.reload();
}
</script>

<style scoped>
.el-tooltip__trigger {
  display: inline-block;
  margin-left: 3px;
}

span.circled-text {
  border: 1px solid black;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  text-align: center;
  font-weight: bold;
}
</style>

<style>
.el-popover.el-popper {
  max-width: 50%;
  word-break: initial !important;
  text-align: initial !important;
}
</style>
