<template lang="pug">
.my-8(
  v-for='needSatisfactionRating in needSatisfactionRatings'
)
  .mb-2
    strong {{needSatisfactionRating.emotional_need.name}}
    el-popover(
      placement='top-end'
      trigger='click'
      :content='needSatisfactionRating.emotional_need.description'
    )
      template(#reference)
        span.circled-text.monospace.js-link i
    a.ml-2(:href='graphLink(needSatisfactionRating)') graph
  div
    EmojiButton(
      v-for='ratingValue in RATINGS_RANGE'
      :needSatisfactionRating='needSatisfactionRating'
      :ratingValue='ratingValue'
      :editable='editable'
    )

button.btn-primary.mt-2.h3(v-if='editable && !submitted' @click='submitCheckIn') Submit Check-in
</template>

<script setup lang="ts">
import { range } from 'lodash-es';
import { storeToRefs } from 'pinia';
import type { PropType } from 'vue';

import { useCheckInsStore } from '@/check_ins/store';
import type { NeedSatisfactionRating, Rating } from '@/check_ins/types';

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
  return window.Routes.history_emotional_need_path(
    needSatisfactionRating.emotional_need.id,
    { rated_user: props.ratedUser },
  );
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
