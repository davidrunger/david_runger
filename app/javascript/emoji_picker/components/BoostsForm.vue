<template lang="pug">
.mt-8
  h2.mb-0 Emoji Boosts
  small These names will be weighted more heavily in the search results.

  //- Stop propagation and prevent default so enter doesn't select an emoji.
  form.mt-2(
    @keydown.stop
    @submit.prevent
  )
    table.m-auto
      thead
        tr
          th Symbol
          th Keyword to boost
          th
      tbody
        tr(v-for="boost in boosts")
          td
            input.w-16.text-center(
              placeholder="Symbol"
              type="text"
              v-model="boost.symbol"
            )
          td
            input.text-center(
              placeholder="Keyword to boost"
              type="text"
              v-model="boost.boostedName"
            )
          td.pl-1
            button.text-red-500.font-bold(@click="removeBoost(boost)") Delete

    .flex.justify-center.gap-1.mt-1
      button.btn-primary.btn-small(@click="addBoost") &nbsp;+ Add a boost
      button.btn-primary.btn-small(@click="saveBoosts") Save boosts
</template>

<script setup lang="ts">
import { boosts } from '@/emoji_picker/emoji_data';
import { http } from '@/lib/http';
import { vueToast } from '@/lib/vue_toasts';
import { api_json_preferences_path } from '@/rails_assets/routes';
import type { EmojiDataWithBoostedName } from '@/types';

function addBoost() {
  boosts.value.push({ symbol: '', boostedName: '' });
}

function removeBoost(boostToRemove: EmojiDataWithBoostedName) {
  boosts.value = boosts.value.filter((boost) => boost !== boostToRemove);
}

async function saveBoosts() {
  await http.patch(api_json_preferences_path(), {
    preference_type: 'emoji_boosts',
    json: boosts,
  });

  vueToast('Saved boosts successfully.');
}
</script>
