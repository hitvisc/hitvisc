<template>
  <button
    type="button"
    class="btn btn-primary"
    @click="changeLang()"
  >
    {{ locale }}
  </button>
</template>

<script lang="ts" setup>
const { locale } = useI18n();

function changeLang() {
  locale.value = locale.value === 'ru' ? 'en' : 'ru';
}
</script>
