<template lang="pug">
aside.hidden-scrollbars.max-h-full.overflow-auto.border-r.border-neutral-400(
  :class="{ collapsed }"
)
  .flex.min-h-full.flex-col
    .sidebar-toggle__container.border-b
      .app-mark.flex.h-full.items-center.gap-2.px-4
        LeafIcon(size="24")
        span Groceries
      button.sidebar-toggle(
        aria-label="Toggle stores sidebar"
        @click="collapsed = !collapsed"
        :class="{ 'rotated-180': expanded }"
      )
        ArrowBarRightIcon(size="29")
    nav
      .store-lists-container.pb-4
        form.add-store.flex(@submit.prevent="handleNewStoreSubmission()")
          .mr-2.flex-1
            ElInput(
              type="text"
              v-model="formData.newStoreName"
              name="newStoreName"
              placeholder="Add a store"
            )
          ElButton(
            native-type="submit"
            :disabled="postingStore || v$.$invalid"
            round
          ) Add
        .store-section-label My stores
        .stores-list
          StoreListEntry(
            v-for="store in groceriesStore.sortedStores"
            :key="store.id"
            :store="store"
          )
        div(v-if="groceriesStore.sortedSpouseStores.length > 0")
          .store-section-label Spouse's stores
          .stores-list
            StoreListEntry(
              v-for="store in groceriesStore.sortedSpouseStores"
              :key="store.id"
              :store="store"
            )
    .partner-tip.mt-auto.p-3.text-center(
      v-if="!bootstrap.spouse && !collapsed"
    ) Tip: You and your partner can automatically view each other's lists. #[a(:href="invitePartnerHref") Invite them to join.]
</template>

<script setup lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { ElButton, ElInput } from 'element-plus';
import { storeToRefs } from 'pinia';
import { computed, reactive, ref } from 'vue';
import { ArrowBarRightIcon, LeafIcon } from 'vue-tabler-icons';

import { bootstrap } from '@/groceries/bootstrap';
import { useGroceriesStore } from '@/groceries/store';
import { useSubscription } from '@/lib/composables/useSubscription';
import { isMobileDevice } from '@/lib/isMobileDevice';
import { new_marriage_path } from '@/rails_assets/routes';

import StoreListEntry from './StoreListEntry.vue';

const formData = reactive({
  newStoreName: '',
});
const collapsed = ref(isMobileDevice());
const groceriesStore = useGroceriesStore();
const vuelidateRules = {
  newStoreName: { required },
};
const v$ = useVuelidate(vuelidateRules, formData);

function handleStoreSelected() {
  if (isMobileDevice()) {
    collapsed.value = true;
  }
}

useSubscription('groceries:store-selected', handleStoreSelected);

const { postingStore } = storeToRefs(groceriesStore);

const expanded = computed(() => !collapsed.value);

async function handleNewStoreSubmission() {
  if (await groceriesStore.createStore(formData.newStoreName)) {
    formData.newStoreName = '';
  }
}

const invitePartnerHref = new_marriage_path({
  redirect_location: window.location.href,
});
</script>

<style lang="scss" scoped>
/* stylelint-disable no-invalid-position-declaration */
/* stylelint-disable-next-line length-zero-no-unit */
@mixin sidebar-width($padding: 0px) {
  @media screen and (width <= 400px) {
    min-width: calc(150px - $padding);
    width: calc(45vw - $padding);
    max-width: calc(180px - $padding);
  }

  @media screen and (width >= 400px) {
    min-width: calc(180px - $padding);
    width: calc(35vw - $padding);
    max-width: calc(280px - $padding);
  }
}
/* stylelint-enable no-invalid-position-declaration */

aside {
  color: #f8f3e8;
  background:
    radial-gradient(
      ellipse at 15% 85%,
      rgb(239, 224, 200, 13%),
      transparent 28%
    ),
    linear-gradient(165deg, #75856c 0%, #61745f 46%, #50634f 100%);
  border-color: #425441;
  box-shadow: 6px 0 22px rgb(50, 65, 52, 14%);
  transition:
    min-width 0.7s,
    width 0.7s,
    max-width 0.7s;

  @include sidebar-width;

  .app-mark,
  .store-section-label,
  :deep(.stores-list__item) {
    opacity: 1;
    transition: opacity 0.7s;
  }

  &.collapsed {
    min-width: 50px;
    width: 50px;
    max-width: 50px;
    overflow-x: hidden;

    .app-mark,
    .store-section-label,
    :deep(.stores-list__item) {
      opacity: 0;
    }

    .overflow-auto {
      overflow-x: hidden;
    }

    nav {
      visibility: hidden;
      opacity: 0;
      pointer-events: none;
      transition:
        opacity 0.2s,
        visibility 0s 0.2s;
    }
  }
}

:deep(.el-sub-menu__title) {
  @include sidebar-width;
}

nav {
  position: relative;
  padding-top: 16px;
  opacity: 1;
  transition: opacity 0.25s 0.15s;

  @include sidebar-width($padding: 32px);
}

.store-lists-container {
  position: relative;
  left: 16px;
}

.add-store {
  padding: 0 2px 18px;

  :deep(.el-input__wrapper) {
    background: rgb(255, 253, 248, 92%);
    border: 1px solid rgb(255, 255, 255, 35%);
    border-radius: 999px;
    box-shadow: 0 4px 14px rgb(45, 57, 47, 13%);
  }

  :deep(.el-button) {
    color: #f8f3e8;
    background: #96576a;
    border-color: #96576a;
    box-shadow: 0 4px 12px rgb(67, 45, 52, 20%);

    &:hover,
    &:focus {
      color: white;
      background: #754052;
      border-color: #754052;
    }
  }
}

.app-mark {
  max-width: calc(100% - 50px);
  overflow: hidden;
  color: #fffaf1;
  font-size: 1.05rem;
  font-weight: 700;
  letter-spacing: 0.02em;
  white-space: nowrap;
}

.store-section-label {
  margin: 5px 4px 4px;
  color: rgb(255, 250, 241, 76%);
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 0.13em;
  text-transform: uppercase;
  white-space: nowrap;
}

.partner-tip {
  color: rgb(255, 250, 241, 82%);
  font-size: 0.82rem;
  line-height: 1.4;

  a,
  a:visited {
    color: #f2d9df;
    font-weight: 700;
  }
}

.sidebar-toggle__container {
  position: sticky;
  top: 0;
  height: 50px;
  z-index: 4;
  background: rgb(58, 76, 59, 48%);
  border-color: rgb(41, 58, 43, 45%);
  backdrop-filter: blur(4px);
}

button.sidebar-toggle {
  position: absolute;
  top: 0;
  right: 0;
  margin-bottom: 8px;
  background: none;
  color: inherit;
  border: none;
  padding: 0;
  font: inherit;
  cursor: pointer;
  outline: inherit;
  height: 50px;
  width: 50px;
  transition:
    transform 0.7s,
    left 0.7s;

  &:hover {
    color: #f2d9df;
  }

  &.rotated-180 {
    transform: rotate(180deg);
  }
}
</style>
