<template>
  <div class="x-icon">
    <svg
      class="icon"
      :style="{
        transform,
        width: size + 'px',
        height: size + 'px',
      }"
    >
      <use :xlink:href="iconHref"></use>
    </svg>
  </div>
</template>

<script lang="ts" setup>
import packageJson from '~/package.json';

const props = defineProps<{
  /** Наименование иконки */
  icon: string;
  /** Размер в пикселях */
  size?: number;
  /** Стили для преобразования иконки (например, поворот на заданный угол) */
  transform?: string;
}>();

const { icon, size = 12, transform = 'none' } = toRefs(props);

const iconHref = computed(
  () => `/assets/svg/sprite.css.svg?v=${packageJson.version}#${icon.value}`,
);
</script>

<style lang="scss" scoped>
.x-icon {
  align-items: center;
  display: inline-flex;
  flex-wrap: nowrap;
  justify-content: center;
}

.icon {
  transition: all ease-in-out 0.1s;
}
</style>
