<template lang="pug">
input(
  type="hidden"
  name="authenticity_token"
  :value="csrfToken()"
)
</template>

<script setup lang="ts">
import { csrfToken } from '@/lib/csrfToken';
</script>
