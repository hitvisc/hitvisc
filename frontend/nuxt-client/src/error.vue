<template>
  <div class="container error">
    <x-icon
      icon="error"
      :size="300"
    />
    <div class="mb-3 status-code">
      {{ error.statusCode }}
    </div>
    <h1 class="section-title section-title-lg">{{ name }}</h1>
    <p class="section-description">{{ message }}</p>
    <div class="btn-list">
      <router-link
        to="/"
        class="btn btn-primary"
      >
        <x-icon
          icon="arrow-left"
          :size="18"
        />

        {{ $t('error.takeMeHomeBtn') }}
      </router-link>
    </div>
  </div>
</template>

<script lang="ts" setup>
import type { NuxtError } from '#app';

definePageMeta({
  layout: 'empty',
  requiresAuth: false,
});

const props = defineProps<{ error: NuxtError }>();
const { error } = toRefs(props);

const { t } = useI18n();

const name = computed(() => {
  switch (error.value.statusCode) {
    case 404:
      return t(`error.${error.value.statusCode}.name`);
    case 403:
      return t(`error.${error.value.statusCode}.name`);
    default:
      return error.value.name;
  }
});

const message = computed(() => {
  switch (error.value.statusCode) {
    case 404:
      return t(`error.${error.value.statusCode}.message`);
    case 403:
      return t(`error.${error.value.statusCode}.message`);
    default:
      return error.value.message;
  }
});
</script>

<style lang="scss" scoped>
.container.error {
  display: flex;
  flex-direction: column;
  justify-content: center;
  text-align: center;
  height: 100%;

  max-width: 45rem;
}

.status-code {
  color: #616876;
  font-size: 4rem;
  font-weight: 300;
  line-height: 1;
  margin: 0 0 1rem;
}

.section-header {
  max-width: 45rem;
  margin: 0 auto 4rem;
}

.section-title {
  color: var(--section-title-color);
  font-size: 1.5rem;
  font-weight: 600;
  line-height: 2.25rem;
}

.section-title-lg {
  font-size: 2rem;
  line-height: 2rem;
  font-weight: 700;
}

.section-description {
  color: var(--section-description-color, inherit);
  font-weight: 400;
  font-size: 1.125rem;
}

.btn-list {
  --btn-list-margin: 0.5rem;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  margin: 0 calc(var(--btn-list-margin) * -1) calc(var(--btn-list-margin) * -1) 0;
}
</style>
