<template>
  <div class="copy-text">
    <span class="badge">{{ source }}</span>

    <x-icon
      v-tooltip="{
        content: copied ? $t('shared.copyText.copied') : $t('shared.copyText.click'),
        hideTriggers: ['hover', 'focus'],
      }"
      icon="icon-box-multiple"
      :size="16"
      class="ps-1 copy-text__icon"
      @click="copy(source)"
    />
  </div>
</template>

<script lang="ts" setup>
const props = defineProps<{ source: string }>();
const { source } = toRefs(props);
const { copied, copy } = useClipboard({
  source,
  legacy: true,
});
</script>

<style lang="scss" scoped>
.copy-text {
  display: inline-flex;

  &__icon {
    cursor: pointer;
    color: #0054a6;

    &:hover {
      color: #4263eb;
    }
  }
}
</style>
