<template lang="pug">
li.flex.items-center.break-word.mb-2(:class="aboutToMoveToClass()")
  input(
    type="checkbox",
    :checked="item.checkInStatus === 'in-cart'"
    @change="toggleItemInCart",
    :disabled="item.checkInStatus === 'skipped'",
    :id="`trip-checkin-item-${item.id}`"
  )
  label.ml-2(:for="`trip-checkin-item-${item.id}`")
    span(:class="{ 'text-gray-500': item.checkInStatus === 'skipped' }")
      span {{ item.name }}
      span(v-if="item.needed > 1") {{ ' ' }} ({{ item.needed }})
    span {{ ' ' }}
    ElTooltip(
      v-if="isSpouseItem(item)"
      content="Spouse item"
      placement="top"
    )
      HeartFilledIcon.text-red-500
    span {{ ' ' }}
    el-button(
      v-if="item.checkInStatus === 'skipped'"
      link
      type="primary"
      @click="moveTo('needed')"
    ) Unskip
    el-button(
      v-else
      link
      type="primary"
      @click="moveTo('skipped')"
    ) Skip
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { storeToRefs } from 'pinia';
import type { PropType } from 'vue';
import { HeartFilledIcon } from 'vue-tabler-icons';

import { useGroceriesStore } from '@/groceries/store';
import type { CheckInStatus, Item } from '@/groceries/types';

const props = defineProps({
  item: {
    type: Object as PropType<Item>,
    required: true,
  },
});

const MOVE_TIMEOUT = 500;
const MOVING_TO_STATUS_TO_CLASS_MAP = {
  'in-cart': 'bg-green-200',
  needed: 'bg-orange-200',
  skipped: 'bg-red-200',
};
const CLEAR_BACKGROUND_COLOR_TIMEOUT = 1200;

const groceriesStore = useGroceriesStore();

const { isSpouseItem } = storeToRefs(groceriesStore);

function aboutToMoveToClass() {
  if (props.item.aboutToMoveTo) {
    return MOVING_TO_STATUS_TO_CLASS_MAP[props.item.aboutToMoveTo];
  }
}

function moveTo(checkInStatus: CheckInStatus) {
  if (props.item.aboutToMoveTo) return;

  groceriesStore.setItemAboutToMoveTo({
    item: props.item,
    aboutToMoveTo: checkInStatus,
  });

  setTimeout(() => {
    groceriesStore.setItemCheckInStatus({
      item: props.item,
      checkInStatus,
    });
  }, MOVE_TIMEOUT);

  setTimeout(() => {
    groceriesStore.setItemAboutToMoveTo({
      item: props.item,
      aboutToMoveTo: null,
    });
  }, CLEAR_BACKGROUND_COLOR_TIMEOUT);
}

function toggleItemInCart() {
  if (props.item.checkInStatus === 'in-cart') {
    moveTo('needed');
  } else {
    moveTo('in-cart');
  }
}
</script>

<style scoped lang="scss">
li {
  transition: all 0.15s ease-out;
}
</style>
