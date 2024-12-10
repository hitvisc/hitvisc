<template>
  <div class="invalid-feedback">
    {{ message }}
  </div>
</template>

<script lang="ts" setup>
const props = defineProps<{ message: string }>();
const { message } = toRefs(props);
</script>
