<template lang="pug">
.sidebar-shell
  button.sidebar-backdrop(
    v-if="compactViewport && drawerOpen"
    aria-label="Close stores sidebar"
    type="button"
    @click="closeDrawer"
    @pointerdown="startClosingSwipe"
  )
  .sidebar-swipe-target(
    v-if="!drawerOpen"
    aria-hidden="true"
    @pointerdown="startOpeningSwipe"
  )
  aside#groceries-stores-sidebar.hidden-scrollbars.max-h-full.overflow-auto.border-r.border-neutral-400(
    :class="{ 'drawer-open': drawerOpen }"
    :aria-hidden="!sidebarExpanded"
    :inert="!sidebarExpanded"
  )
    .flex.min-h-full.flex-col
      .sidebar-toggle__container.border-b
        .app-mark.flex.h-full.items-center.gap-2.px-4
          LeafIcon(size="24")
          span Groceries
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
      .partner-tip.mt-auto.p-3.text-center(v-if="!bootstrap.spouse") Tip: You and your partner can automatically view each other's lists. #[a(:href="invitePartnerHref") Invite them to join.]
  button.sidebar-toggle(
    :aria-expanded="drawerOpen"
    aria-controls="groceries-stores-sidebar"
    :aria-label="drawerOpen ? 'Hide stores sidebar' : 'Show stores sidebar'"
    type="button"
    :class="{ 'drawer-open': drawerOpen }"
    @click="toggleDrawer"
  )
    ArrowBarRightIcon(size="29")
</template>

<script setup lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { ElButton, ElInput } from 'element-plus';
import { storeToRefs } from 'pinia';
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue';
import { ArrowBarRightIcon, LeafIcon } from 'vue-tabler-icons';

import { bootstrap } from '@/groceries/bootstrap';
import { useGroceriesStore } from '@/groceries/store';
import { useSubscription } from '@/lib/composables/useSubscription';
import { new_marriage_path } from '@/rails_assets/routes';

import StoreListEntry from './StoreListEntry.vue';

const formData = reactive({
  newStoreName: '',
});
const smallScreenBreakpoint = getComputedStyle(document.documentElement)
  .getPropertyValue('--small-screen-breakpoint')
  .trim();
const compactViewportQuery = window.matchMedia(
  `(max-width: ${smallScreenBreakpoint})`,
);
const compactViewport = ref(compactViewportQuery.matches);
const drawerOpen = ref(false);
const groceriesStore = useGroceriesStore();
const vuelidateRules = {
  newStoreName: { required },
};
const v$ = useVuelidate(vuelidateRules, formData);
let swipePointerId: number | undefined;
let swipeStartX: number | undefined;

function handleStoreSelected() {
  closeDrawer();
}

useSubscription('groceries:store-selected', handleStoreSelected);

const { postingStore } = storeToRefs(groceriesStore);

const sidebarExpanded = computed(
  () => !compactViewport.value || drawerOpen.value,
);

function toggleDrawer() {
  drawerOpen.value = !drawerOpen.value;
}

function closeDrawer() {
  drawerOpen.value = false;
}

function updateCompactViewport(event: MediaQueryListEvent) {
  compactViewport.value = event.matches;

  if (!event.matches) closeDrawer();
}

function handleKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape' && drawerOpen.value) closeDrawer();
}

function startOpeningSwipe(event: PointerEvent) {
  if (drawerOpen.value || event.clientX > 24) return;

  startSwipe(event);
}

function startClosingSwipe(event: PointerEvent) {
  startSwipe(event);
}

function startSwipe(event: PointerEvent) {
  if (!compactViewport.value || !event.isPrimary) return;

  swipePointerId = event.pointerId;
  swipeStartX = event.clientX;
}

function finishSwipe(event: PointerEvent) {
  if (event.pointerId !== swipePointerId || swipeStartX === undefined) return;

  const swipeDistance = event.clientX - swipeStartX;
  swipePointerId = undefined;
  swipeStartX = undefined;

  if (!drawerOpen.value && swipeDistance >= 48) drawerOpen.value = true;
  else if (drawerOpen.value && swipeDistance <= -48) closeDrawer();
}

function cancelSwipe(event: PointerEvent) {
  if (event.pointerId !== swipePointerId) return;

  swipePointerId = undefined;
  swipeStartX = undefined;
}

async function handleNewStoreSubmission() {
  if (await groceriesStore.createStore(formData.newStoreName)) {
    formData.newStoreName = '';
    closeDrawer();
  }
}

const invitePartnerHref = new_marriage_path({
  redirect_location: window.location.href,
});

onMounted(() => {
  compactViewportQuery.addEventListener('change', updateCompactViewport);
  window.addEventListener('keydown', handleKeydown);
  window.addEventListener('pointerup', finishSwipe);
  window.addEventListener('pointercancel', cancelSwipe);
});

onBeforeUnmount(() => {
  compactViewportQuery.removeEventListener('change', updateCompactViewport);
  window.removeEventListener('keydown', handleKeydown);
  window.removeEventListener('pointerup', finishSwipe);
  window.removeEventListener('pointercancel', cancelSwipe);
});
</script>

<style lang="scss" scoped>
@use 'css/sass_variables' as *;

.sidebar-shell {
  --sidebar-rail-width: 6px;
  --sidebar-toggle-gap: 16px;
  --sidebar-toggle-size: 44px;
  --sidebar-drawer-width: min(320px, calc(100vw - 68px));
  --sidebar-drawer-transition-duration: 0.85s;

  position: relative;
  z-index: 20;
  flex: 0 0 var(--sidebar-rail-width);
  width: var(--sidebar-rail-width);
  min-width: var(--sidebar-rail-width);
}

aside {
  position: absolute;
  inset: 0 auto 0 0;
  z-index: 2;
  width: var(--sidebar-drawer-width);
  height: 100%;
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
  transform: translateX(calc(-100% + var(--sidebar-rail-width)));
  transition: transform var(--sidebar-drawer-transition-duration)
    cubic-bezier(0.2, 0.75, 0.25, 1);

  &.drawer-open {
    transform: translateX(0);
  }
}

nav {
  position: relative;
  padding-top: 16px;
  width: calc(100% - 32px);
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
  max-width: 100%;
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
  top: 19px;
  left: calc(var(--sidebar-rail-width) + var(--sidebar-toggle-gap));
  z-index: 3;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: var(--sidebar-toggle-size);
  height: var(--sidebar-toggle-size);
  padding: 0;
  color: #fffaf1;
  background: #61745f;
  border: 1px solid rgb(255, 250, 241, 36%);
  border-radius: 50%;
  box-shadow: 0 6px 16px rgb(43, 56, 44, 28%);
  cursor: pointer;
  transition:
    background-color 0.2s ease,
    box-shadow 0.2s ease,
    left var(--sidebar-drawer-transition-duration)
      cubic-bezier(0.2, 0.75, 0.25, 1),
    transform var(--sidebar-drawer-transition-duration)
      cubic-bezier(0.2, 0.75, 0.25, 1);

  &:hover,
  &:focus-visible {
    color: #f2d9df;
    background: #50634f;
    box-shadow: 0 8px 20px rgb(43, 56, 44, 35%);
  }

  &.drawer-open {
    left: calc(var(--sidebar-drawer-width) + var(--sidebar-toggle-gap));
    transform: rotate(180deg);
  }
}

.sidebar-backdrop {
  position: absolute;
  inset: 0;
  z-index: 1;
  width: 100vw;
  height: 100%;
  padding: 0;
  background: rgb(44, 57, 46, 55%);
  border: 0;
  cursor: pointer;
  backdrop-filter: blur(2px);
}

.sidebar-swipe-target {
  position: absolute;
  inset: 0 auto 0 0;
  z-index: 1;
  width: 24px;
  touch-action: pan-y;
}

@media not all and (max-width: $small-screen-breakpoint) {
  .sidebar-shell {
    z-index: auto;
    display: block;
    flex: 0 0 auto;
    width: clamp(180px, 35vw, 280px);
    min-width: clamp(180px, 35vw, 280px);
  }

  aside {
    position: relative;
    width: 100%;
    transform: none;
  }

  nav {
    width: calc(100% - 32px);
  }

  button.sidebar-toggle,
  .sidebar-swipe-target {
    display: none;
  }
}

@media (prefers-reduced-motion: reduce) {
  aside,
  button.sidebar-toggle {
    transition-duration: 0.01ms;
  }
}
</style>
